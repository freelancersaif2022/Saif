import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_names.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/url_resolver.dart';
import '../../engine/engine_event.dart';
import '../../shared/dialogs.dart';
import '../downloads/download_item.dart';
import '../downloads/downloads_controller.dart';
import '../downloads/downloads_screen.dart';
import '../permissions/site_permission_repository.dart';
import '../settings/settings_controller.dart';
import '../tabs/tabs_controller.dart';

/// Answers WebView requests that need the user: downloads, file uploads,
/// site permissions, HTTP authentication, external apps and popups.
class BrowserInteractionHost extends ConsumerStatefulWidget {
  const BrowserInteractionHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BrowserInteractionHost> createState() => _BrowserInteractionHostState();
}

class _BrowserInteractionHostState extends ConsumerState<BrowserInteractionHost> {
  StreamSubscription<EngineEvent>? _events;
  StreamSubscription<DownloadItem>? _completions;

  @override
  void initState() {
    super.initState();
    _events = ref.read(browserEngineProvider).events.listen(_onEvent);
    _completions = ref.read(downloadsProvider.notifier).completions.listen(_onDownloadComplete);
  }

  @override
  void dispose() {
    _events?.cancel();
    _completions?.cancel();
    super.dispose();
  }

  void _onEvent(EngineEvent e) {
    if (!mounted) return;
    switch (e.type) {
      case 'download':
        _onDownload(e);
      case 'fileChooser':
        _onFileChooser(e);
      case 'permissionRequest':
        _onPermission(e);
      case 'httpAuthRequest':
        _onHttpAuth(e);
      case 'externalApp':
        _onExternalApp(e);
      case 'popupBlocked':
        showMessage(context, 'Pop-up blocked');
    }
  }

  void _onDownloadComplete(DownloadItem item) {
    if (!mounted) return;
    showMessage(
      context,
      'Downloaded ${item.fileName}',
      action: SnackBarAction(label: 'Open', onPressed: () => ref.read(downloadsProvider.notifier).open(item.id)),
    );
  }

  // ------------------------------------------------------------ downloads

  Future<void> _onDownload(EngineEvent e) async {
    final url = e.str('url') ?? '';
    final tabs = ref.read(tabsProvider);
    final tab = tabs.byId(e.tabId);
    final mime = e.str('mimeType');
    final name = FileNames.guess(url, e.str('contentDisposition'), mime);
    final size = e.integer('contentLength') ?? -1;
    final incognito = tab?.incognito ?? false;

    // A popup that only existed to start a download is closed.
    if (tab != null && tab.parentId != null && !UrlResolver.isWebUrl(e.str('pageUrl'))) {
      unawaited(ref.read(tabsProvider.notifier).close(tab.id));
    }

    String? fileName = name;
    if (ref.read(settingsProvider).askBeforeDownload) {
      fileName = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) =>
            _DownloadPrompt(fileName: name, size: size, host: UrlResolver.hostOf(url) ?? '', mimeType: mime),
      );
    }
    if (fileName == null || !mounted) return;
    try {
      await ref
          .read(downloadsProvider.notifier)
          .start(
            DownloadRequest(
              url: url,
              fileName: fileName,
              mimeType: mime,
              contentLength: size,
              userAgent: e.str('userAgent'),
              referer: e.str('pageUrl'),
              incognito: incognito,
              tabId: e.tabId,
            ),
          );
      if (!mounted) return;
      showMessage(
        context,
        'Downloading $fileName',
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DownloadsScreen())),
        ),
      );
    } on DownloadStartException catch (error) {
      if (mounted) showMessage(context, error.message);
    }
  }

  // ------------------------------------------------------------ file input

  Future<void> _onFileChooser(EngineEvent e) async {
    final requestId = e.integer('requestId')!;
    final engine = ref.read(browserEngineProvider);
    final accept = e.strings('acceptTypes').map((t) => t.toLowerCase()).toList();
    final any = accept.isEmpty || accept.contains('*/*');
    final images =
        any ||
        accept.any(
          (t) => t.startsWith('image/') || const ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic'].contains(t),
        );
    final videos =
        any || accept.any((t) => t.startsWith('video/') || const ['.mp4', '.webm', '.mov', '.3gp'].contains(t));

    if (e.flag('capture') && (images || videos)) {
      await engine.respondFileChooser(requestId, images ? 'camera' : 'camcorder');
      return;
    }

    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                e.flag('multiple') ? 'Choose files to upload' : 'Choose a file to upload',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (images || videos)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(images && videos ? 'Photos & videos' : (images ? 'Photos' : 'Videos')),
                onTap: () => Navigator.pop(context, 'media'),
              ),
            if (images)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
            if (videos)
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Record a video'),
                onTap: () => Navigator.pop(context, 'camcorder'),
              ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Browse files'),
              onTap: () => Navigator.pop(context, 'files'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    await engine.respondFileChooser(requestId, source ?? 'cancel');
  }

  // ------------------------------------------------------------ permissions

  Future<void> _onPermission(EngineEvent e) async {
    final requestId = e.integer('requestId')!;
    final engine = ref.read(browserEngineProvider);
    final origin = e.str('origin') ?? '';
    final tab = ref.read(tabsProvider).byId(e.tabId);
    final incognito = tab?.incognito ?? true;
    final requested = e.strings('resources').map(SitePermission.fromName).whereType<SitePermission>().toList();
    final repo = ref.read(sitePermissionRepositoryProvider);
    final normalized = UrlResolver.originOf(origin) ?? origin;

    final granted = <SitePermission>[];
    final undecided = <SitePermission>[];
    for (final p in requested) {
      final decision = incognito ? null : await repo.decision(normalized, p);
      if (decision == PermissionDecision.allow) {
        granted.add(p);
      } else if (decision == null) {
        undecided.add(p);
      }
    }

    if (undecided.isNotEmpty && mounted) {
      final allow = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PermissionDialog(origin: normalized, permissions: undecided),
      );
      if (allow == null) {
        await engine.respondPermission(requestId, const []);
        return;
      }
      if (!incognito) {
        for (final p in undecided) {
          await repo.set(normalized, p, allow ? PermissionDecision.allow : PermissionDecision.block);
        }
      }
      if (allow) granted.addAll(undecided);
    }

    // Android runtime permissions for the capabilities the user allowed.
    final android = granted.where((p) => p != SitePermission.protectedMedia).map((p) => p.name).toList();
    if (android.isNotEmpty) {
      final ok = await engine.requestAndroidPermissions(android);
      if (!ok) {
        granted.removeWhere((p) => p != SitePermission.protectedMedia);
        if (mounted) {
          showMessage(
            context,
            'Saif Browser needs Android permission to share this with sites',
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => ref.read(systemBridgeProvider).openAppSettings(),
            ),
          );
        }
      }
    }
    await engine.respondPermission(requestId, granted.map((p) => p.name).toList(), remember: false);
  }

  // ------------------------------------------------------------ http auth

  Future<void> _onHttpAuth(EngineEvent e) async {
    final requestId = e.integer('requestId')!;
    final result = await showDialog<(String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _HttpAuthDialog(host: e.str('host') ?? '', realm: e.str('realm')),
    );
    await ref.read(browserEngineProvider).respondHttpAuth(requestId, username: result?.$1, password: result?.$2);
  }

  // ------------------------------------------------------------ external apps

  Future<void> _onExternalApp(EngineEvent e) async {
    final url = e.str('url') ?? '';
    final scheme = Uri.tryParse(url)?.scheme ?? 'app';
    final fallback = e.str('fallbackUrl');
    final open = await confirm(
      context,
      title: 'Open in another app?',
      message: 'This page wants to open a “$scheme” link in another app on your device.',
      confirmLabel: 'Open',
    );
    if (!open) {
      if (fallback != null) await ref.read(tabsProvider.notifier).navigate(fallback, tabId: e.tabId);
      return;
    }
    final ok = await ref.read(systemBridgeProvider).openExternal(url);
    if (ok) return;
    if (fallback != null) {
      await ref.read(tabsProvider.notifier).navigate(fallback, tabId: e.tabId);
    } else if (mounted) {
      showMessage(context, 'No app on this device can open this link');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _DownloadPrompt extends StatefulWidget {
  const _DownloadPrompt({required this.fileName, required this.size, required this.host, this.mimeType});

  final String fileName;
  final int size;
  final String host;
  final String? mimeType;

  @override
  State<_DownloadPrompt> createState() => _DownloadPromptState();
}

class _DownloadPromptState extends State<_DownloadPrompt> {
  late final _name = TextEditingController(text: widget.fileName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.download_rounded, color: palette.onAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download file?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        [
                          if (widget.size > 0) Formatters.bytes(widget.size),
                          if (widget.host.isNotEmpty) widget.host,
                        ].join(' · '),
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'File name'),
            ),
            if (widget.mimeType == 'application/vnd.android.package-archive') ...[
              const SizedBox(height: 10),
              Text(
                'This type of file can harm your device. Only download it if you trust the source.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final name = FileNames.sanitize(_name.text);
                      Navigator.pop(context, name.isEmpty ? widget.fileName : name);
                    },
                    child: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDialog extends StatelessWidget {
  const _PermissionDialog({required this.origin, required this.permissions});

  final String origin;
  final List<SitePermission> permissions;

  IconData _icon(SitePermission p) => switch (p) {
    SitePermission.camera => Icons.videocam_outlined,
    SitePermission.microphone => Icons.mic_none_rounded,
    SitePermission.location => Icons.location_on_outlined,
    SitePermission.protectedMedia => Icons.verified_user_outlined,
  };

  String _verb(SitePermission p) => switch (p) {
    SitePermission.camera => 'Use your camera',
    SitePermission.microphone => 'Use your microphone',
    SitePermission.location => 'Know your location',
    SitePermission.protectedMedia => 'Play protected content (uses a device identifier)',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${Uri.tryParse(origin)?.host ?? origin} wants to'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in permissions)
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(_icon(p)), title: Text(_verb(p))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Block')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Allow')),
      ],
    );
  }
}

class _HttpAuthDialog extends StatefulWidget {
  const _HttpAuthDialog({required this.host, this.realm});

  final String host;
  final String? realm;

  @override
  State<_HttpAuthDialog> createState() => _HttpAuthDialogState();
}

class _HttpAuthDialogState extends State<_HttpAuthDialog> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign in'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.host} requires a username and password${widget.realm == null || widget.realm!.isEmpty ? '' : ' (“${widget.realm}”)'}.',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _user,
            autofocus: true,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pass,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, (_user.text, _pass.text)), child: const Text('Sign in')),
      ],
    );
  }
}
