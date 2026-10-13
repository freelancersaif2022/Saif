import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/url_resolver.dart';
import 'credential_repository.dart';

/// Adds or edits a saved login. Only saves when the user taps Save.
Future<bool> showCredentialEditor(
  BuildContext context, {
  Credential? existing,
  String? initialPassword,
  String? origin,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CredentialEditor(existing: existing, initialPassword: initialPassword, origin: origin),
  );
  return saved ?? false;
}

class _CredentialEditor extends ConsumerStatefulWidget {
  const _CredentialEditor({this.existing, this.initialPassword, this.origin});

  final Credential? existing;
  final String? initialPassword;
  final String? origin;

  @override
  ConsumerState<_CredentialEditor> createState() => _CredentialEditorState();
}

class _CredentialEditorState extends ConsumerState<_CredentialEditor> {
  late final _site = TextEditingController(text: widget.existing?.origin ?? widget.origin ?? '');
  late final _user = TextEditingController(text: widget.existing?.username ?? '');
  late final _pass = TextEditingController(text: widget.initialPassword ?? '');
  bool _obscure = true;
  String? _siteError;
  String? _passError;
  bool _saving = false;

  @override
  void dispose() {
    _site.dispose();
    _user.dispose();
    _pass.clear();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final url = UrlResolver.toUrl(_site.text);
    final origin = UrlResolver.originOf(url);
    setState(() {
      _siteError = origin == null ? 'Enter the website address' : null;
      _passError = _pass.text.isEmpty ? 'Enter a password' : null;
    });
    if (origin == null || _pass.text.isEmpty) return;
    setState(() => _saving = true);
    final repo = ref.read(credentialRepositoryProvider);
    try {
      final existing = widget.existing;
      if (existing != null) {
        await repo.update(existing.id, origin: origin, username: _user.text.trim(), password: _pass.text);
      } else {
        await repo.save(origin: origin, username: _user.text.trim(), password: _pass.text);
      }
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _passError = 'Could not encrypt the password on this device';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Save password' : 'Edit password',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('Stored only on this device, encrypted with a key kept in the Android Keystore.'),
          const SizedBox(height: 16),
          TextField(
            controller: _site,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(labelText: 'Website', hintText: 'example.com', errorText: _siteError),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _user,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pass,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passError,
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
