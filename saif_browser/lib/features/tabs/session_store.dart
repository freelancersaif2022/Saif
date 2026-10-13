import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/storage/atomic_file.dart';
import 'browser_tab.dart';

/// Saved regular tab (private tabs are never persisted).
class SavedTab {
  const SavedTab({required this.url, required this.title, this.desktopMode = false});

  final String url;
  final String title;
  final bool desktopMode;
}

class SavedSession {
  const SavedSession({required this.tabs, required this.activeIndex, required this.recentlyClosed});

  final List<SavedTab> tabs;
  final int activeIndex;
  final List<ClosedTab> recentlyClosed;
}

/// Persists regular tabs to a JSON file with atomic writes.
class SessionStore {
  SessionStore(String directory) : _file = File(p.join(directory, 'session.json'));

  final File _file;
  static const _version = 1;

  Future<SavedSession?> load() async {
    final raw = await AtomicFile.readString(_file);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, Object?> || json['version'] != _version) return null;
      final tabs = <SavedTab>[];
      for (final t in (json['tabs'] as List<Object?>? ?? const [])) {
        if (t is Map<String, Object?> && t['url'] is String) {
          tabs.add(
            SavedTab(url: t['url']! as String, title: t['title'] as String? ?? '', desktopMode: t['desktop'] == true),
          );
        }
      }
      final closed = [for (final c in (json['closed'] as List<Object?>? ?? const [])) ?ClosedTab.fromJson(c)];
      final active = json['active'] as int? ?? 0;
      return SavedSession(
        tabs: tabs,
        activeIndex: tabs.isEmpty ? 0 : active.clamp(0, tabs.length - 1),
        recentlyClosed: closed,
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> save(TabsState state) {
    final tabs = state.regular;
    final activeIndex = tabs.indexWhere((t) => t.id == state.activeRegularId);
    final json = {
      'version': _version,
      'active': activeIndex < 0 ? 0 : activeIndex,
      'tabs': [
        for (final t in tabs) {'url': t.showNtp ? '' : t.url, 'title': t.title, 'desktop': t.desktopMode},
      ],
      'closed': [for (final c in state.recentlyClosed) c.toJson()],
    };
    return AtomicFile.writeString(_file, jsonEncode(json));
  }

  Future<void> clear() async {
    if (await _file.exists()) await _file.delete();
  }
}
