import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../permissions/site_permission_repository.dart';

/// Remembered per-site permission decisions.
class SiteSettingsScreen extends ConsumerStatefulWidget {
  const SiteSettingsScreen({super.key});

  @override
  ConsumerState<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends ConsumerState<SiteSettingsScreen> {
  List<SitePermissionEntry> _entries = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await ref.read(sitePermissionRepositoryProvider).all();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final origins = <String, List<SitePermissionEntry>>{};
    for (final e in _entries) {
      origins.putIfAbsent(e.origin, () => []).add(e);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Site permissions')),
      body: !_loaded
          ? const SizedBox.shrink()
          : origins.isEmpty
          ? const EmptyState(
              icon: Icons.tune_rounded,
              title: 'No site permissions',
              message: 'When a site asks for your camera, microphone or location, your choice is listed here.',
            )
          : ListView(
              children: [
                for (final origin in origins.keys) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                    child: Text(
                      Uri.tryParse(origin)?.host ?? origin,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final e in origins[origin]!)
                    ListTile(
                      title: Text(e.permission.label),
                      subtitle: Text(e.decision == PermissionDecision.allow ? 'Allowed' : 'Blocked'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: e.decision == PermissionDecision.allow,
                            onChanged: (allow) async {
                              await ref
                                  .read(sitePermissionRepositoryProvider)
                                  .set(
                                    e.origin,
                                    e.permission,
                                    allow ? PermissionDecision.allow : PermissionDecision.block,
                                  );
                              await _load();
                            },
                          ),
                          IconButton(
                            tooltip: 'Reset',
                            onPressed: () async {
                              await ref.read(sitePermissionRepositoryProvider).remove(e.origin, e.permission);
                              await _load();
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}
