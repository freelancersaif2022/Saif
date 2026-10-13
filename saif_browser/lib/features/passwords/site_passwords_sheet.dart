import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../tabs/browser_tab.dart';
import 'credential_editor.dart';
import 'credential_repository.dart';
import 'device_auth.dart';

/// Saved logins for the current site: fill one into the page or save a new
/// one. Filling only happens on an explicit tap, after authentication, and
/// only if the page's origin still matches the saved origin.
Future<void> showSitePasswordsSheet(BuildContext context, WidgetRef ref, BrowserTab tab) async {
  final origin = UrlResolver.originOf(tab.url);
  if (origin == null) return;
  final creds = await ref.read(credentialRepositoryProvider).forOrigin(origin);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Text(
              'Passwords for ${UrlResolver.hostOf(tab.url)}',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (!UrlResolver.isSecure(tab.url))
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
              child: Text(
                'This page is not secure (HTTP). Passwords you enter could be seen by others on the network.',
                style: TextStyle(color: Theme.of(sheetContext).colorScheme.error),
              ),
            ),
          for (final c in creds)
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(c.username.isEmpty ? '(no username)' : c.username),
              trailing: FilledButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await _fill(context, ref, tab, c);
                },
                child: const Text('Fill'),
              ),
            ),
          if (creds.isEmpty) const ListTile(title: Text('No saved passwords for this site')),
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: const Text('Save a password for this site'),
            onTap: () async {
              Navigator.pop(sheetContext);
              final saved = await showCredentialEditor(context, origin: origin);
              if (saved && context.mounted) showMessage(context, 'Password saved');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<void> _fill(BuildContext context, WidgetRef ref, BrowserTab tab, Credential credential) async {
  final outcome = await ref.read(vaultLockProvider).unlock('Fill saved password');
  if (outcome != AuthOutcome.success) {
    if (context.mounted && outcome == AuthOutcome.unavailable) {
      showMessage(context, 'Set up a screen lock to use saved passwords');
    }
    return;
  }
  String? password;
  try {
    password = await ref.read(credentialRepositoryProvider).revealPassword(credential.id);
  } on Object {
    password = null;
  }
  if (password == null) {
    if (context.mounted) showMessage(context, 'This password can’t be decrypted on this device');
    return;
  }
  final status = await ref
      .read(browserEngineProvider)
      .fillCredential(tab.id, origin: credential.origin, username: credential.username, password: password);
  if (!context.mounted) return;
  switch (status) {
    case 'ok':
      showMessage(context, 'Filled');
    case 'no_field':
      showMessage(context, 'No password field found on this page');
    case 'origin_mismatch':
      showMessage(context, 'The page changed to a different site; nothing was filled');
    default:
      showMessage(context, 'Could not fill this page');
  }
}
