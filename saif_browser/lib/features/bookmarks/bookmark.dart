import 'package:flutter/foundation.dart';

@immutable
class Bookmark {
  const Bookmark({
    required this.id,
    required this.title,
    this.url,
    this.parentId,
    this.isFolder = false,
    this.position = 0,
    required this.createdAt,
  });

  factory Bookmark.fromRow(Map<String, Object?> row) => Bookmark(
    id: row['id']! as int,
    title: row['title']! as String,
    url: row['url'] as String?,
    parentId: row['parent_id'] as int?,
    isFolder: row['is_folder'] == 1,
    position: row['position'] as int? ?? 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
  );

  final int id;
  final String title;
  final String? url;
  final int? parentId;
  final bool isFolder;
  final int position;
  final DateTime createdAt;
}
