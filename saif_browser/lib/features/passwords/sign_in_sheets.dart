import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum SaveChoice { save, notNow, never }

/// Username/password prompt for HTTP authentication from a website or a
/// network proxy (for example a manual Wi-Fi proxy).
Future<(String, String)?> showSignInSheet(
  BuildContext context, {
  required String host,
  String? realm,
  required bool isProxy,
  String? initialUsername,
  bool failed = false,
}) {
  return showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    builder: (_) =>
        _SignInSheet(host: host, realm: realm, isProxy: isProxy, initialUsername: initialUsername, failed: failed),
  );
}

class _SignInSheet extends StatefulWidget {
  const _SignInSheet({
    required this.host,
    this.realm,
    required this.isProxy,
    this.initialUsername,
    required this.failed,
  });

  final String host;
  final String? realm;
  final bool isProxy;
  final String? initialUsername;
  final bool failed;

  @override
  State<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<_SignInSheet> {
  late final _user = TextEditingController(text: widget.initialUsername ?? '');
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _user.dispose();
    _pass.clear();
    _pass.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, (_user.text.trim(), _pass.text));

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final error = Theme.of(context).colorScheme.error;
    final realm = widget.realm?.trim() ?? '';
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(14)),
                child: Icon(
                  widget.isProxy ? Icons.vpn_lock_rounded : Icons.lock_person_rounded,
                  color: palette.onAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isProxy ? 'Proxy sign-in' : 'Sign in',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.host,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.isProxy
                ? 'The network proxy requires a username and password.'
                : 'This site requires a username and password${realm.isEmpty ? '' : ' for “$realm”'}.',
            style: TextStyle(color: palette.textSecondary, height: 1.4),
          ),
          if (widget.failed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('The username or password was not accepted.', style: TextStyle(color: error)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _user,
            autofocus: _user.text.isEmpty,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pass,
            autofocus: _user.text.isNotEmpty,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.key_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(onPressed: _submit, child: const Text('Sign in')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Save password?" prompt with Save / Not now (and optionally Never).
Future<SaveChoice> showSavePasswordSheet(
  BuildContext context, {
  required String title,
  required String place,
  required String username,
  bool isUpdate = false,
  bool allowNever = true,
  IconData icon = Icons.key_rounded,
}) async {
  final choice = await showModalBottomSheet<SaveChoice>(
    context: context,
    useSafeArea: true,
    builder: (context) {
      final palette = context.palette;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: palette.onAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        'Encrypted and stored only on this device',
                        style: TextStyle(color: palette.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.public_rounded, size: 20, color: palette.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 20, color: palette.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(username.isEmpty ? '(no username)' : username)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.key_rounded, size: 20, color: palette.textSecondary),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('••••••••••', style: TextStyle(letterSpacing: 1.5))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, SaveChoice.notNow),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, SaveChoice.save),
                    child: Text(isUpdate ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
            if (allowNever && !isUpdate)
              TextButton(
                onPressed: () => Navigator.pop(context, SaveChoice.never),
                child: Text('Never for this site', style: TextStyle(color: palette.textSecondary)),
              ),
          ],
        ),
      );
    },
  );
  return choice ?? SaveChoice.notNow;
}
