import 'package:flutter/foundation.dart';

@immutable
class HistoryEntry {
  const HistoryEntry({required this.id, required this.url, required this.title, required this.visitedAt});

  factory HistoryEntry.fromRow(Map<String, Object?> row) => HistoryEntry(
    id: row['id']! as int,
    url: row['url']! as String,
    title: row['title'] as String? ?? '',
    visitedAt: DateTime.fromMillisecondsSinceEpoch(row['visited_at']! as int),
  );

  final int id;
  final String url;
  final String title;
  final DateTime visitedAt;
}

/// A frequently visited site shown on the new tab page.
@immutable
class TopSite {
  const TopSite({required this.url, required this.title, required this.host, required this.visits});

  final String url;
  final String title;
  final String host;
  final int visits;
}
