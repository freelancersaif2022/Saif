import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/dialogs.dart';
import '../history/history_screen.dart';

/// Clears regular-browsing data. Private-session data is separate and is
/// removed when private tabs close.
class ClearDataScreen extends ConsumerStatefulWidget {
  const ClearDataScreen({super.key});

  @override
  ConsumerState<ClearDataScreen> createState() => _ClearDataScreenState();
}

class _ClearDataScreenState extends ConsumerState<ClearDataScreen> {
  static const _ranges = [
    ('Last hour', Duration(hours: 1)),
    ('Last 24 hours', Duration(days: 1)),
    ('Last 7 days', Duration(days: 7)),
    ('Last 4 weeks', Duration(days: 28)),
    ('All time', Duration.zero),
  ];

  int _range = 4;
  bool _history = true;
  bool _cookies = true;
  bool _cache = true;
  bool _passwords = false;
  bool _permissions = false;
  bool _working = false;

  Future<void> _clear() async {
    if (_passwords) {
      final ok = await confirm(
        context,
        title: 'Delete all saved passwords?',
        message: 'This cannot be undone.',
        confirmLabel: 'Delete',
        destructive: true,
      );
      if (!ok) return;
    }
    setState(() => _working = true);
    final duration = _ranges[_range].$2;
    final since = duration == Duration.zero ? null : DateTime.now().subtract(duration);
    if (_history) {
      await ref.read(historyRepositoryProvider).clear(since: since);
      await ref.read(faviconRepositoryProvider).prune();
    }
    await ref
        .read(browserEngineProvider)
        .clearBrowsingData(
          cookies: _cookies,
          storage: _cookies,
          cache: _cache,
          httpAuth: _cookies,
          permissions: _permissions,
        );
    if (_passwords) {
      await ref.read(credentialRepositoryProvider).clear();
      await ref.read(httpAuthRepositoryProvider).clear();
    }
    if (_permissions) await ref.read(sitePermissionRepositoryProvider).clear();
    ref.read(dataRevisionProvider.notifier).bump();
    if (!mounted) return;
    setState(() => _working = false);
    showMessage(context, 'Browsing data cleared');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clear browsing data')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: DropdownButtonFormField<int>(
              initialValue: _range,
              decoration: const InputDecoration(labelText: 'Time range (history)'),
              items: [for (var i = 0; i < _ranges.length; i++) DropdownMenuItem(value: i, child: Text(_ranges[i].$1))],
              onChanged: (v) => setState(() => _range = v ?? _range),
            ),
          ),
          CheckboxListTile(
            value: _history,
            onChanged: (v) => setState(() => _history = v ?? false),
            title: const Text('Browsing history'),
            secondary: const Icon(Icons.history_rounded),
          ),
          CheckboxListTile(
            value: _cookies,
            onChanged: (v) => setState(() => _cookies = v ?? false),
            title: const Text('Cookies and site data'),
            subtitle: const Text('Signs you out of most sites. Always clears all time.'),
            secondary: const Icon(Icons.cookie_outlined),
          ),
          CheckboxListTile(
            value: _cache,
            onChanged: (v) => setState(() => _cache = v ?? false),
            title: const Text('Cached images and files'),
            subtitle: const Text('Always clears all time'),
            secondary: const Icon(Icons.image_outlined),
          ),
          CheckboxListTile(
            value: _permissions,
            onChanged: (v) => setState(() => _permissions = v ?? false),
            title: const Text('Site permissions'),
            secondary: const Icon(Icons.tune_rounded),
          ),
          CheckboxListTile(
            value: _passwords,
            onChanged: (v) => setState(() => _passwords = v ?? false),
            title: const Text('Saved passwords'),
            secondary: const Icon(Icons.key_outlined),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton.icon(
              onPressed: _working || !(_history || _cookies || _cache || _passwords || _permissions) ? null : _clear,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear data'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HistoryScreen())),
            child: const Text('Manage history'),
          ),
        ],
      ),
    );
  }
}
