import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/utils/file_names.dart';
import '../../engine/system_bridge.dart';
import '../proxy/proxy_controller.dart';
import '../proxy/proxy_models.dart';
import '../settings/browser_settings.dart';
import '../settings/settings_controller.dart';
import 'download_item.dart';
import 'http_downloader.dart';

/// What the page asked to download.
class DownloadRequest {
  const DownloadRequest({
    required this.url,
    required this.fileName,
    this.mimeType,
    this.contentLength = -1,
    this.userAgent,
    this.referer,
    required this.incognito,
    required this.tabId,
  });

  final String url;
  final String fileName;
  final String? mimeType;
  final int contentLength;
  final String? userAgent;
  final String? referer;
  final bool incognito;
  final String tabId;
}

class DownloadStartException implements Exception {
  const DownloadStartException(this.message);

  final String message;

  @override
  String toString() => message;
}

final downloadsProvider = NotifierProvider<DownloadsController, List<DownloadItem>>(DownloadsController.new);

/// Tracks every download. System downloads are polled only while the app is
/// visible and something is active; nothing runs in the background here.
class DownloadsController extends Notifier<List<DownloadItem>> {
  final Map<int, HttpDownloadTask> _tasks = {};
  final Map<int, (int, DateTime)> _samples = {};
  final StreamController<DownloadItem> _completions = StreamController.broadcast();
  Timer? _pollTimer;
  AppLifecycleListener? _lifecycle;
  bool _visible = true;
  bool _loaded = false;
  Future<void>? _loading;

  /// Emits each download that finishes successfully.
  Stream<DownloadItem> get completions => _completions.stream;

  SystemBridge get _system => ref.read(systemBridgeProvider);

  @override
  List<DownloadItem> build() {
    _lifecycle = AppLifecycleListener(
      onShow: () {
        _visible = true;
        _syncPolling();
      },
      onHide: () {
        _visible = false;
        _syncPolling();
      },
    );
    ref.onDispose(() {
      _pollTimer?.cancel();
      _lifecycle?.dispose();
      for (final task in _tasks.values) {
        task.cancel();
      }
      _completions.close();
    });
    _loading = _load();
    return const [];
  }

  Future<void> ensureLoaded() => _loading ?? Future.value();

  Future<void> _load() async {
    final repo = ref.read(downloadRepositoryProvider);
    await repo.markInterrupted();
    final items = await repo.all();
    if (!ref.mounted) return;
    state = items;
    _loaded = true;
    _syncPolling();
  }

  void _replace(DownloadItem item) {
    if (!ref.mounted) return;
    state = [for (final d in state) d.id == item.id ? item : d];
  }

  Future<void> _persist(DownloadItem item) async {
    if (ref.mounted) await ref.read(downloadRepositoryProvider).update(item);
  }

  Future<String> _appDir() => _system.appDownloadsDir();

  Future<String> _uniqueName(String name) async {
    final taken = state.map((d) => d.fileName).toSet();
    final dir = Directory(await _appDir());
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        taken.add(p.basename(entity.path));
      }
    }
    return FileNames.unique(FileNames.sanitize(name).isEmpty ? 'download' : FileNames.sanitize(name), taken);
  }

  /// Starts a download the user confirmed. Throws [DownloadStartException].
  Future<DownloadItem> start(DownloadRequest request) async {
    await ensureLoaded();
    final scheme = Uri.tryParse(request.url)?.scheme.toLowerCase() ?? '';
    final fileName = await _uniqueName(request.fileName);
    if (scheme == 'data' || scheme == 'blob') {
      return _saveInline(request, fileName, scheme);
    }
    if (scheme != 'http' && scheme != 'https') {
      throw const DownloadStartException('This link cannot be downloaded');
    }

    String? route;
    try {
      route = ref.read(proxyControllerProvider.notifier).downloadRoute();
    } on ProxyFailure catch (failure) {
      throw DownloadStartException(failure.kind.message);
    }

    final base = DownloadItem(
      id: 0,
      url: request.url,
      fileName: fileName,
      mimeType: request.mimeType,
      totalBytes: request.contentLength,
      status: DownloadStatus.queued,
      engine: route == null ? DownloadEngine.system : DownloadEngine.app,
      userAgent: request.userAgent,
      referer: request.incognito ? null : request.referer,
      incognito: request.incognito,
      createdAt: DateTime.now(),
    );

    if (route == null) {
      int systemId;
      try {
        systemId = await _system.enqueueDownload(
          url: request.url,
          fileName: fileName,
          mimeType: request.mimeType,
          userAgent: request.userAgent,
          referer: base.referer,
          incognito: request.incognito,
        );
      } on Object catch (e) {
        throw DownloadStartException('Download could not start: ${_describe(e)}');
      }
      final id = await ref.read(downloadRepositoryProvider).insert(base.copyWith(systemId: systemId));
      final item = base.copyWith(id: id, systemId: systemId);
      state = [item, ...state];
      _syncPolling();
      return item;
    }

    final path = p.join(await _appDir(), fileName);
    final id = await ref.read(downloadRepositoryProvider).insert(base.copyWith(filePath: path));
    final item = base.copyWith(id: id, filePath: path);
    state = [item, ...state];
    unawaited(_runApp(item, route));
    return item;
  }

  String _describe(Object e) => e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'unknown error';

  Future<DownloadItem> _saveInline(DownloadRequest request, String fileName, String scheme) async {
    List<int> bytes;
    if (scheme == 'data') {
      try {
        bytes = UriData.parse(request.url).contentAsBytes();
      } on FormatException {
        throw const DownloadStartException('Invalid data link');
      }
    } else {
      final encoded = await ref.read(browserEngineProvider).readBlob(request.tabId, request.url);
      if (encoded == null) {
        throw const DownloadStartException('This file is no longer available on the page');
      }
      bytes = base64.decode(encoded);
    }
    final path = p.join(await _appDir(), fileName);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    final now = DateTime.now();
    final item = DownloadItem(
      id: 0,
      url: scheme == 'data' ? 'data:' : request.url,
      fileName: fileName,
      mimeType: request.mimeType ?? FileNames.mimeForName(fileName),
      totalBytes: bytes.length,
      receivedBytes: bytes.length,
      status: DownloadStatus.completed,
      engine: DownloadEngine.inline,
      filePath: path,
      incognito: request.incognito,
      createdAt: now,
      completedAt: now,
    );
    final id = await ref.read(downloadRepositoryProvider).insert(item);
    final saved = item.copyWith(id: id);
    state = [saved, ...state];
    _onCompleted(saved);
    return saved;
  }

  Future<void> _runApp(DownloadItem item, String route) async {
    final headers = <String, String>{};
    if (item.userAgent != null) headers[HttpHeaders.userAgentHeader] = item.userAgent!;
    if (item.referer != null) headers[HttpHeaders.refererHeader] = item.referer!;
    final cookies = await ref.read(browserEngineProvider).getCookies(item.url, incognito: item.incognito);
    if (cookies != null && cookies.isNotEmpty) headers[HttpHeaders.cookieHeader] = cookies;

    var lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    final task = HttpDownloadTask(
      url: Uri.parse(item.url),
      target: File(item.filePath!),
      headers: headers,
      proxy: route,
      onProgress: (received, total) {
        final now = DateTime.now();
        if (now.difference(lastUpdate) < const Duration(milliseconds: 250)) return;
        lastUpdate = now;
        final current = _find(item.id);
        if (current == null) return;
        _replace(
          current.copyWith(
            status: DownloadStatus.running,
            receivedBytes: received,
            totalBytes: total,
            bytesPerSecond: _rate(item.id, received, now),
          ),
        );
      },
    );
    _tasks[item.id] = task;
    _replace(item.copyWith(status: DownloadStatus.running, clearError: true));
    try {
      final size = await task.run();
      final done = _find(item.id)?.copyWith(
        status: DownloadStatus.completed,
        receivedBytes: size,
        totalBytes: size,
        completedAt: DateTime.now(),
        bytesPerSecond: 0,
        clearError: true,
      );
      if (done != null) {
        _replace(done);
        await _persist(done);
        _onCompleted(done);
      }
    } on HttpDownloadException catch (e) {
      final current = _find(item.id);
      if (current != null) {
        final failed = current.copyWith(
          status: task.isCanceled ? DownloadStatus.canceled : DownloadStatus.failed,
          error: task.isCanceled ? null : e.message,
          bytesPerSecond: 0,
        );
        _replace(failed);
        await _persist(failed);
      }
    } finally {
      _tasks.remove(item.id);
      _samples.remove(item.id);
    }
  }

  DownloadItem? _find(int id) {
    for (final d in state) {
      if (d.id == id) return d;
    }
    return null;
  }

  double _rate(int id, int bytes, DateTime now) {
    final previous = _samples[id];
    _samples[id] = (bytes, now);
    if (previous == null) return 0;
    final seconds = now.difference(previous.$2).inMilliseconds / 1000;
    if (seconds <= 0) return 0;
    final rate = (bytes - previous.$1) / seconds;
    return rate < 0 ? 0 : rate;
  }

  void _syncPolling() {
    final needsPolling =
        _loaded && _visible && state.any((d) => d.engine == DownloadEngine.system && d.isActive && d.systemId != null);
    if (needsPolling && _pollTimer == null) {
      _pollTimer = Timer.periodic(const Duration(milliseconds: 800), (_) => _poll());
      _poll();
    } else if (!needsPolling) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  bool _polling = false;

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final active = state.where((d) => d.engine == DownloadEngine.system && d.isActive && d.systemId != null);
      final ids = active.map((d) => d.systemId!).toList();
      if (ids.isEmpty) return;
      final statuses = await _system.queryDownloads(ids);
      final now = DateTime.now();
      for (final s in statuses) {
        final item = state.where((d) => d.systemId == s.id).firstOrNull;
        if (item == null) continue;
        final status = switch (s.status) {
          'pending' => DownloadStatus.queued,
          'running' => DownloadStatus.running,
          'paused' => DownloadStatus.paused,
          'completed' => DownloadStatus.completed,
          'missing' => DownloadStatus.canceled,
          _ => DownloadStatus.failed,
        };
        final updated = item.copyWith(
          status: status,
          receivedBytes: s.received > 0 ? s.received : item.receivedBytes,
          totalBytes: s.total > 0 ? s.total : item.totalBytes,
          bytesPerSecond: status == DownloadStatus.running ? _rate(item.id, s.received, now) : 0,
          error: status == DownloadStatus.failed ? _systemReason(s.reason) : null,
          completedAt: status == DownloadStatus.completed ? now : null,
        );
        _replace(updated);
        if (updated.status != item.status) {
          await _persist(updated);
          if (updated.status == DownloadStatus.completed) _onCompleted(updated);
        }
      }
    } on Object {
      // Transient query failure; the next tick retries.
    } finally {
      _polling = false;
      _syncPolling();
    }
  }

  static String _systemReason(int reason) => switch (reason) {
    1006 => 'Not enough storage space',
    1007 => 'Storage not available',
    1009 => 'File already exists',
    1004 => 'Network error',
    1005 => 'Too many redirects',
    1002 || 1003 => 'The server sent an unexpected response',
    1008 => 'The server does not support resuming',
    _ when reason >= 400 && reason < 600 => 'Server responded with HTTP $reason',
    _ => 'Download failed',
  };

  void _onCompleted(DownloadItem item) {
    _completions.add(item);
    final settings = ref.read(settingsProvider);
    if (settings.downloadLocation == DownloadLocation.ask) {
      unawaited(saveCopy(item.id));
    } else if (settings.openWhenComplete) {
      unawaited(open(item.id));
    }
  }

  Future<void> cancel(int id) async {
    final item = _find(id);
    if (item == null || !item.isActive) return;
    if (item.engine == DownloadEngine.system && item.systemId != null) {
      await _system.removeDownload(item.systemId!);
    } else {
      _tasks[id]?.cancel();
      final path = item.filePath;
      if (path != null) await File(path).delete().catchError((Object _) => File(path));
    }
    final canceled = item.copyWith(status: DownloadStatus.canceled, bytesPerSecond: 0);
    _replace(canceled);
    await _persist(canceled);
    _syncPolling();
  }

  Future<void> retry(int id) async {
    final item = _find(id);
    if (item == null || item.isActive || item.engine == DownloadEngine.inline) return;
    String? route;
    try {
      route = ref.read(proxyControllerProvider.notifier).downloadRoute();
    } on ProxyFailure catch (failure) {
      final failed = item.copyWith(status: DownloadStatus.failed, error: failure.kind.message);
      _replace(failed);
      await _persist(failed);
      return;
    }
    if (item.engine == DownloadEngine.system && route == null) {
      try {
        final systemId = await _system.enqueueDownload(
          url: item.url,
          fileName: item.fileName,
          mimeType: item.mimeType,
          userAgent: item.userAgent,
          referer: item.referer,
          incognito: item.incognito,
        );
        final queued = item.copyWith(
          systemId: systemId,
          status: DownloadStatus.queued,
          receivedBytes: 0,
          clearError: true,
        );
        _replace(queued);
        await _persist(queued);
        _syncPolling();
      } on Object catch (e) {
        final failed = item.copyWith(status: DownloadStatus.failed, error: _describe(e));
        _replace(failed);
        await _persist(failed);
      }
      return;
    }
    if (route == null) {
      // App-engine downloads only exist because of a proxy; without one, hand
      // the retry to the system download manager.
      final fresh = await start(
        DownloadRequest(
          url: item.url,
          fileName: item.fileName,
          mimeType: item.mimeType,
          userAgent: item.userAgent,
          referer: item.referer,
          incognito: item.incognito,
          tabId: '',
        ),
      );
      await remove(item.id);
      _replace(fresh);
      return;
    }
    final path = item.filePath ?? p.join(await _appDir(), item.fileName);
    final queued = item.copyWith(status: DownloadStatus.queued, filePath: path, clearError: true);
    _replace(queued);
    await _persist(queued);
    unawaited(_runApp(queued, route));
  }

  /// Removes the entry; with [deleteFile] the downloaded file is deleted too.
  Future<void> remove(int id, {bool deleteFile = false}) async {
    final item = _find(id);
    if (item == null) return;
    if (item.isActive) await cancel(id);
    if (deleteFile) {
      if (item.engine == DownloadEngine.system && item.systemId != null) {
        await _system.removeDownload(item.systemId!);
      } else if (item.filePath != null) {
        final file = File(item.filePath!);
        if (await file.exists()) await file.delete();
      }
    }
    await ref.read(downloadRepositoryProvider).delete(id);
    state = state.where((d) => d.id != id).toList();
    _syncPolling();
  }

  Future<void> clearFinished() async {
    await ref.read(downloadRepositoryProvider).clearFinished();
    state = state.where((d) => d.isActive).toList();
  }

  Future<bool> open(int id) async {
    final item = _find(id);
    if (item == null || item.status != DownloadStatus.completed) return false;
    return _system.openFile(
      systemId: item.engine == DownloadEngine.system ? item.systemId : null,
      path: item.engine == DownloadEngine.system ? null : item.filePath,
      mimeType: item.mimeType ?? FileNames.mimeForName(item.fileName),
    );
  }

  Future<bool> share(int id) async {
    final item = _find(id);
    if (item == null || item.status != DownloadStatus.completed) return false;
    return _system.shareFile(
      systemId: item.engine == DownloadEngine.system ? item.systemId : null,
      path: item.engine == DownloadEngine.system ? null : item.filePath,
      mimeType: item.mimeType ?? FileNames.mimeForName(item.fileName),
    );
  }

  /// Copies the file to a location the user picks (Storage Access Framework).
  Future<bool> saveCopy(int id) async {
    final item = _find(id);
    if (item == null || item.status != DownloadStatus.completed) return false;
    return _system.saveCopy(
      systemId: item.engine == DownloadEngine.system ? item.systemId : null,
      path: item.engine == DownloadEngine.system ? null : item.filePath,
      fileName: item.fileName,
      mimeType: item.mimeType ?? FileNames.mimeForName(item.fileName),
    );
  }

  /// Forgets private-session download entries (files the user saved stay).
  Future<void> forgetIncognito() async {
    await ref.read(downloadRepositoryProvider).deleteIncognito();
    state = state.where((d) => !d.incognito || d.isActive).toList();
  }
}
