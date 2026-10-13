import 'dart:async';

import 'package:flutter/services.dart';

/// Status of a download handled by Android's DownloadManager.
class SystemDownloadStatus {
  const SystemDownloadStatus({
    required this.id,
    required this.status,
    this.received = 0,
    this.total = -1,
    this.reason = 0,
  });

  factory SystemDownloadStatus.fromMap(Map<Object?, Object?> map) => SystemDownloadStatus(
    id: (map['id'] as num).toInt(),
    status: map['status'] as String? ?? 'failed',
    received: (map['received'] as num?)?.toInt() ?? 0,
    total: (map['total'] as num?)?.toInt() ?? -1,
    reason: (map['reason'] as num?)?.toInt() ?? 0,
  );

  final int id;

  /// pending, running, paused, completed, failed or missing.
  final String status;
  final int received;
  final int total;
  final int reason;
}

/// Something shared with or opened in the app by another app.
class IncomingIntent {
  const IncomingIntent({this.url, this.text});

  final String? url;
  final String? text;
}

/// Android services that are not part of the WebView itself.
abstract class SystemBridge {
  Stream<IncomingIntent> get intents;
  Future<IncomingIntent?> consumeInitialIntent();

  Future<Uint8List> encrypt(Uint8List data, String associatedData);
  Future<Uint8List> decrypt(Uint8List data, String associatedData);

  Future<void> setSecure(bool secure);
  Future<void> moveToBack();
  Future<bool> openExternal(String url);
  Future<bool> shareText(String text, {String? subject});
  Future<bool> openAppSettings();

  /// Private app directory for the tab session file.
  Future<String> appSupportDir();
  Future<String> appDownloadsDir();
  Future<int> enqueueDownload({
    required String url,
    required String fileName,
    String? mimeType,
    String? userAgent,
    String? referer,
    required bool incognito,
  });
  Future<List<SystemDownloadStatus>> queryDownloads(List<int> ids);
  Future<void> removeDownload(int id);
  Future<bool> openFile({int? systemId, String? path, String? mimeType});
  Future<bool> shareFile({int? systemId, String? path, String? mimeType});
  Future<bool> saveCopy({int? systemId, String? path, required String fileName, String? mimeType});
}

class MethodChannelSystemBridge implements SystemBridge {
  MethodChannelSystemBridge({MethodChannel? channel}) : _channel = channel ?? const MethodChannel('saif/system') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onIntent' && call.arguments is Map) {
        _intents.add(_parseIntent(call.arguments as Map<Object?, Object?>));
      }
      return null;
    });
  }

  final MethodChannel _channel;
  final StreamController<IncomingIntent> _intents = StreamController.broadcast();

  static IncomingIntent _parseIntent(Map<Object?, Object?> map) =>
      IncomingIntent(url: map['url'] as String?, text: map['text'] as String?);

  @override
  Stream<IncomingIntent> get intents => _intents.stream;

  @override
  Future<IncomingIntent?> consumeInitialIntent() async {
    final map = await _channel.invokeMethod<Map<Object?, Object?>>('consumeInitialIntent');
    return map == null ? null : _parseIntent(map);
  }

  @override
  Future<Uint8List> encrypt(Uint8List data, String associatedData) async =>
      (await _channel.invokeMethod<Uint8List>('encrypt', {'data': data, 'aad': associatedData}))!;

  @override
  Future<Uint8List> decrypt(Uint8List data, String associatedData) async =>
      (await _channel.invokeMethod<Uint8List>('decrypt', {'data': data, 'aad': associatedData}))!;

  @override
  Future<void> setSecure(bool secure) => _channel.invokeMethod('setSecure', {'secure': secure});

  @override
  Future<void> moveToBack() => _channel.invokeMethod('moveToBack');

  @override
  Future<bool> openExternal(String url) async =>
      await _channel.invokeMethod<bool>('openExternal', {'url': url}) ?? false;

  @override
  Future<bool> shareText(String text, {String? subject}) async =>
      await _channel.invokeMethod<bool>('shareText', {'text': text, 'subject': subject}) ?? false;

  @override
  Future<bool> openAppSettings() async => await _channel.invokeMethod<bool>('openAppSettings') ?? false;

  @override
  Future<String> appSupportDir() async => (await _channel.invokeMethod<String>('appSupportDir'))!;

  @override
  Future<String> appDownloadsDir() async => (await _channel.invokeMethod<String>('appDownloadsDir'))!;

  @override
  Future<int> enqueueDownload({
    required String url,
    required String fileName,
    String? mimeType,
    String? userAgent,
    String? referer,
    required bool incognito,
  }) async {
    final id = await _channel.invokeMethod<num>('enqueueDownload', {
      'url': url,
      'fileName': fileName,
      'mimeType': mimeType,
      'userAgent': userAgent,
      'referer': referer,
      'incognito': incognito,
    });
    return id!.toInt();
  }

  @override
  Future<List<SystemDownloadStatus>> queryDownloads(List<int> ids) async {
    final list = await _channel.invokeMethod<List<Object?>>('queryDownloads', {'ids': ids});
    return (list ?? const []).whereType<Map<Object?, Object?>>().map(SystemDownloadStatus.fromMap).toList();
  }

  @override
  Future<void> removeDownload(int id) => _channel.invokeMethod('removeDownload', {'id': id});

  @override
  Future<bool> openFile({int? systemId, String? path, String? mimeType}) async =>
      await _channel.invokeMethod<bool>('openFile', {'systemId': systemId, 'path': path, 'mimeType': mimeType}) ??
      false;

  @override
  Future<bool> shareFile({int? systemId, String? path, String? mimeType}) async =>
      await _channel.invokeMethod<bool>('shareFile', {'systemId': systemId, 'path': path, 'mimeType': mimeType}) ??
      false;

  @override
  Future<bool> saveCopy({int? systemId, String? path, required String fileName, String? mimeType}) async =>
      await _channel.invokeMethod<bool>('saveCopy', {
        'systemId': systemId,
        'path': path,
        'fileName': fileName,
        'mimeType': mimeType,
      }) ??
      false;
}
