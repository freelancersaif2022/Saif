import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/secure_window.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/host_favicon.dart';
import 'credential_editor.dart';
import 'credential_repository.dart';
import 'device_auth.dart';

/// Saved passwords. Screenshots are blocked while open and the list is only
/// shown after device authentication (when enabled in settings).
class PasswordsScreen extends ConsumerStatefulWidget {
  const PasswordsScreen({super.key});

  @override
  ConsumerState<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends ConsumerState<PasswordsScreen> {
  bool _unlocked = false;
  bool _unavailable = false;
  List<Credential> _items = const [];
  String _query = '';
  late final SecureWindowController _secure = ref.read(secureWindowProvider.notifier);

  @override
  void initState() {
    super.initState();
    _secure.set('passwords', true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    _secure.set('passwords', false);
    super.dispose();
  }

  Future<void> _unlock() async {
    final outcome = await ref.read(vaultLockProvider).unlock('Unlock saved passwords');
    if (!mounted) return;
    setState(() {
      _unlocked = outcome == AuthOutcome.success;
      _unavailable = outcome == AuthOutcome.unavailable;
    });
    if (_unlocked) await _load();
  }

  Future<void> _load() async {
    final items = await ref.read(credentialRepositoryProvider).all(query: _query);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _showDetail(Credential c) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CredentialDetail(credential: c),
    );
    await _load();
  }

  Future<void> _clearAll() async {
    final ok = await confirm(
      context,
      title: 'Delete all saved passwords?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete all',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(credentialRepositoryProvider).clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwords'),
        actions: [
          if (_unlocked && _items.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (_) => _clearAll(),
              itemBuilder: (_) => const [PopupMenuItem(value: 'clear', child: Text('Delete all passwords'))],
            ),
        ],
      ),
      floatingActionButton: _unlocked
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (await showCredentialEditor(context)) await _load();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            )
          : null,
      body: !_unlocked
          ? _Locked(unavailable: _unavailable, onUnlock: _unlock)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search passwords',
                    ),
                    onChanged: (v) {
                      _query = v;
                      _load();
                    },
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? EmptyState(
                          icon: Icons.key_outlined,
                          title: _query.isEmpty ? 'No saved passwords' : 'No matches',
                          message: _query.isEmpty
                              ? 'Save a password from a site’s menu (⋮ → Passwords for this site) or tap Add.'
                              : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: _items.length,
                          itemBuilder: (context, i) {
                            final c = _items[i];
                            return ListTile(
                              leading: HostFavicon(url: c.origin, size: 28),
                              title: Text(c.host),
                              subtitle: Text(c.username.isEmpty ? '(no username)' : c.username),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => _showDetail(c),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({required this.unavailable, required this.onUnlock});

  final bool unavailable;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 56, color: context.palette.textSecondary),
            const SizedBox(height: 16),
            Text(
              unavailable ? 'Set up a screen lock' : 'Passwords are locked',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              unavailable
                  ? 'To protect saved passwords, set a PIN, pattern, password or biometric unlock in Android settings. '
                        'You can also turn off “Require screen lock” in Settings → Security.'
                  : 'Verify it’s you to view and manage saved passwords.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialDetail extends ConsumerStatefulWidget {
  const _CredentialDetail({required this.credential});

  final Credential credential;

  @override
  ConsumerState<_CredentialDetail> createState() => _CredentialDetailState();
}

class _CredentialDetailState extends ConsumerState<_CredentialDetail> {
  String? _password;

  Future<String?> _reveal() async {
    final outcome = await ref.read(vaultLockProvider).unlock('Show saved password');
    if (outcome != AuthOutcome.success) return null;
    try {
      return await ref.read(credentialRepositoryProvider).revealPassword(widget.credential.id);
    } on Object {
      if (mounted) showMessage(context, 'This password can’t be decrypted on this device');
      return null;
    }
  }

  @override
  void dispose() {
    _password = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.credential;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              HostFavicon(url: c.origin, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.host,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(c.origin, style: TextStyle(color: palette.textSecondary)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Username'),
            subtitle: Text(c.username.isEmpty ? '(none)' : c.username),
            trailing: IconButton(
              tooltip: 'Copy username',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: c.username));
                showMessage(context, 'Username copied');
              },
              icon: const Icon(Icons.copy_rounded),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Password'),
            subtitle: Text(_password ?? '••••••••••', style: const TextStyle(fontFamily: 'monospace')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: _password == null ? 'Show password' : 'Hide password',
                  onPressed: () async {
                    if (_password != null) {
                      setState(() => _password = null);
                      return;
                    }
                    final value = await _reveal();
                    if (mounted && value != null) setState(() => _password = value);
                  },
                  icon: Icon(_password == null ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
                IconButton(
                  tooltip: 'Copy password',
                  onPressed: () async {
                    final value = _password ?? await _reveal();
                    if (value == null) return;
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) showMessage(context, 'Password copied');
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await confirm(
                      context,
                      title: 'Delete password?',
                      confirmLabel: 'Delete',
                      destructive: true,
                    );
                    if (!ok) return;
                    await ref.read(credentialRepositoryProvider).delete(c.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                  label: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final current = _password ?? await _reveal();
                    if (current == null || !context.mounted) return;
                    final saved = await showCredentialEditor(context, existing: c, initialPassword: current);
                    if (saved && context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
