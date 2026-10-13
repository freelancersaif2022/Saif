import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/empty_state.dart';
import 'proxy_controller.dart';
import 'proxy_models.dart';

class ProxyScreen extends ConsumerStatefulWidget {
  const ProxyScreen({super.key});

  @override
  ConsumerState<ProxyScreen> createState() => _ProxyScreenState();
}

class _ProxyScreenState extends ConsumerState<ProxyScreen> {
  @override
  Widget build(BuildContext context) {
    final status = ref.watch(proxyControllerProvider);
    final proxies = ref.watch(proxyListProvider);
    final controller = ref.read(proxyControllerProvider.notifier);
    final strict = ref.watch(sharedPreferencesProvider).getBool(ProxyController.strictKey) ?? false;
    final supported = ref.read(engineInfoProvider).proxyOverride;
    return Scaffold(
      appBar: AppBar(title: const Text('Proxy')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add proxy'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _StatusCard(status: status, onRetry: controller.retry, onDisconnect: controller.disconnect),
          if (!supported)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                ProxyFailureKind.unsupported.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SwitchListTile(
            title: const Text('Proxy-only mode'),
            subtitle: const Text(
              'Block all browser traffic unless a proxy is connected. Pages and downloads fail instead of '
              'using your direct connection.',
            ),
            value: strict,
            onChanged: supported
                ? (v) async {
                    await controller.setStrictMode(v);
                    setState(() {});
                  }
                : null,
          ),
          const Divider(),
          switch (proxies) {
            AsyncData(:final value) when value.isEmpty => const Padding(
              padding: EdgeInsets.only(top: 32),
              child: EmptyState(
                icon: Icons.vpn_lock_outlined,
                title: 'No proxies',
                message: 'Add an HTTP, HTTPS or SOCKS5 proxy to route browsing through it.',
              ),
            ),
            AsyncData(:final value) => Column(
              children: [for (final p in value) _ProxyTile(profile: p, status: status, onEdit: () => _edit(p))],
            ),
            AsyncError(:final error) => Padding(padding: const EdgeInsets.all(20), child: Text('$error')),
            _ => const SizedBox(height: 80),
          },
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              'How it works: the browser runs a private relay on this device (127.0.0.1) and points Android '
              'System WebView at it; the relay forwards every request through your proxy, including SOCKS5 '
              'and proxy authentication. Host names are resolved by the proxy. WebRTC (real-time audio/video) '
              'can use UDP outside the proxy, and Android’s own services are not affected.',
              style: TextStyle(color: context.palette.textSecondary, fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(ProxyProfile? profile) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProxyEditor(profile: profile),
    );
    if (saved == true) {
      ref.read(proxyRevisionProvider.notifier).bump();
      final status = ref.read(proxyControllerProvider);
      if (profile != null && status.profileId == profile.id && status.state == ProxyConnectionState.connected) {
        await ref.read(proxyControllerProvider.notifier).connect(profile.id);
      }
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.onRetry, required this.onDisconnect});

  final ProxyStatus status;
  final VoidCallback onRetry;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final error = Theme.of(context).colorScheme.error;
    final (IconData icon, String title, Color bg, Color fg) = switch (status.state) {
      ProxyConnectionState.connected => (Icons.verified_user_rounded, 'Connected', palette.accent, Colors.black),
      ProxyConnectionState.connecting => (
        Icons.sync_rounded,
        'Connecting…',
        palette.surface,
        Theme.of(context).colorScheme.onSurface,
      ),
      ProxyConnectionState.failed => (Icons.error_outline_rounded, 'Failed', error, Colors.white),
      ProxyConnectionState.disconnected =>
        status.blockingDirect
            ? (
                Icons.block_rounded,
                'Disconnected — traffic blocked',
                palette.surfaceStrong,
                Theme.of(context).colorScheme.onSurface,
              )
            : (
                Icons.power_settings_new_rounded,
                'Disconnected',
                palette.surface,
                Theme.of(context).colorScheme.onSurface,
              ),
    };
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (status.state == ProxyConnectionState.connecting)
                SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
              else
                Icon(icon, color: fg, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (status.profileName != null && status.state != ProxyConnectionState.disconnected) ...[
            const SizedBox(height: 6),
            Text(status.profileName!, style: TextStyle(color: fg)),
          ],
          if (status.failure != null) ...[
            const SizedBox(height: 6),
            Text(status.failure.toString(), style: TextStyle(color: fg)),
          ],
          if (status.state == ProxyConnectionState.failed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: palette.accent, foregroundColor: Colors.black),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: fg),
                  onPressed: onDisconnect,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProxyTile extends ConsumerWidget {
  const _ProxyTile({required this.profile, required this.status, required this.onEdit});

  final ProxyProfile profile;
  final ProxyStatus status;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(proxyControllerProvider.notifier);
    final isCurrent = status.profileId == profile.id;
    final connected = isCurrent && status.state == ProxyConnectionState.connected;
    final connecting = isCurrent && status.state == ProxyConnectionState.connecting;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: connected ? context.palette.accent : context.palette.surface,
        foregroundColor: Colors.black,
        child: Text(profile.type.label.substring(0, 1)),
      ),
      title: Text(profile.name),
      subtitle: Text(
        '${profile.type.label} · ${profile.address}${profile.hasAuth ? ' · ${profile.username}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onEdit,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (connected || connecting)
            OutlinedButton(onPressed: controller.disconnect, child: const Text('Disconnect'))
          else
            FilledButton(onPressed: () => controller.connect(profile.id), child: const Text('Connect')),
          PopupMenuButton<String>(
            onSelected: (action) async {
              if (action == 'edit') onEdit();
              if (action == 'delete') {
                final ok = await confirm(
                  context,
                  title: 'Delete proxy “${profile.name}”?',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (!ok) return;
                await ref.read(proxyRepositoryProvider).delete(profile.id);
                await controller.onProfileDeleted(profile.id);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProxyEditor extends ConsumerStatefulWidget {
  const _ProxyEditor({this.profile});

  final ProxyProfile? profile;

  @override
  ConsumerState<_ProxyEditor> createState() => _ProxyEditorState();
}

class _ProxyEditorState extends ConsumerState<_ProxyEditor> {
  late final _name = TextEditingController(text: widget.profile?.name ?? '');
  late final _host = TextEditingController(text: widget.profile?.host ?? '');
  late final _port = TextEditingController(text: widget.profile?.port.toString() ?? '');
  late final _user = TextEditingController(text: widget.profile?.username ?? '');
  final _pass = TextEditingController();
  late ProxyType _type = widget.profile?.type ?? ProxyType.http;
  bool _obscure = true;
  String? _hostError;
  String? _portError;

  @override
  void dispose() {
    for (final c in [_name, _host, _port, _user, _pass]) {
      c.dispose();
    }
    super.dispose();
  }

  static final _hostPattern = RegExp(
    r'^([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$',
  );

  Future<void> _save() async {
    final host = _host.text.trim().replaceAll(RegExp(r'^\[|\]$'), '');
    final port = int.tryParse(_port.text.trim());
    final validHost =
        host.isNotEmpty &&
        (_hostPattern.hasMatch(host) || Uri.tryParse('http://[$host]/') != null && host.contains(':'));
    setState(() {
      _hostError = validHost ? null : 'Enter a host name or IP address';
      _portError = port == null || port < 1 || port > 65535 ? 'Port must be 1–65535' : null;
    });
    if (!validHost || _portError != null) return;
    final repo = ref.read(proxyRepositoryProvider);
    final profile = widget.profile;
    // An empty password field keeps the saved password when editing.
    final String? password = _pass.text.isEmpty ? null : _pass.text;
    if (profile == null) {
      await repo.add(
        name: _name.text,
        type: _type,
        host: host,
        port: port!,
        username: _user.text.trim(),
        password: password,
      );
    } else {
      await repo.update(
        profile.id,
        name: _name.text,
        type: _type,
        host: host,
        port: port!,
        username: _user.text.trim(),
        password: _user.text.trim().isEmpty ? '' : password,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.profile != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editing ? 'Edit proxy' : 'Add proxy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ProxyType>(
              segments: [for (final t in ProxyType.values) ButtonSegment(value: t, label: Text(t.label))],
              selected: {_type},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _host,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: InputDecoration(labelText: 'Host or IP', errorText: _hostError),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Port', errorText: _portError),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _user,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Username (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              decoration: InputDecoration(
                labelText: 'Password (optional)',
                helperText: editing && widget.profile!.hasPassword
                    ? 'Leave empty to keep the saved password'
                    : 'Encrypted on this device',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),
            if (_type == ProxyType.https) ...[
              const SizedBox(height: 10),
              Text(
                'HTTPS: the connection to the proxy itself is encrypted with TLS and its certificate is verified.',
                style: TextStyle(color: context.palette.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
