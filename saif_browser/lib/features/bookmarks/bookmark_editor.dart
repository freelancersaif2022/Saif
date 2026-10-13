import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import 'bookmark.dart';

/// Edits a bookmark or folder: title, URL and parent folder.
Future<void> showBookmarkEditor(BuildContext context, WidgetRef ref, {required Bookmark bookmark}) async {
  final folders = await ref.read(bookmarkRepositoryProvider).folders();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BookmarkEditor(bookmark: bookmark, folders: folders.where((f) => f.id != bookmark.id).toList()),
  );
}

class _BookmarkEditor extends ConsumerStatefulWidget {
  const _BookmarkEditor({required this.bookmark, required this.folders});

  final Bookmark bookmark;
  final List<Bookmark> folders;

  @override
  ConsumerState<_BookmarkEditor> createState() => _BookmarkEditorState();
}

class _BookmarkEditorState extends ConsumerState<_BookmarkEditor> {
  late final _title = TextEditingController(text: widget.bookmark.title);
  late final _url = TextEditingController(text: widget.bookmark.url ?? '');
  late int? _parent = widget.bookmark.parentId;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    String? url;
    if (!widget.bookmark.isFolder) {
      url = UrlResolver.toUrl(_url.text);
      if (url == null) {
        setState(() => _error = 'Enter a valid web address');
        return;
      }
    }
    try {
      await ref
          .read(bookmarkRepositoryProvider)
          .update(
            widget.bookmark.id,
            title: _title.text.trim().isEmpty ? (url ?? 'Folder') : _title.text,
            url: url,
            parentId: _parent,
          );
    } on ArgumentError catch (e) {
      setState(() => _error = e.message.toString());
      return;
    }
    ref.read(dataRevisionProvider.notifier).bump();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: widget.bookmark.isFolder ? 'Delete folder and its contents?' : 'Delete bookmark?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(bookmarkRepositoryProvider).delete(widget.bookmark.id);
    ref.read(dataRevisionProvider.notifier).bump();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isFolder = widget.bookmark.isFolder;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isFolder ? 'Edit folder' : 'Edit bookmark',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          if (!isFolder) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: 'URL', errorText: _error),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _parent,
            decoration: const InputDecoration(labelText: 'Folder'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Bookmarks')),
              for (final f in widget.folders) DropdownMenuItem<int?>(value: f.id, child: Text(f.title)),
            ],
            onChanged: (v) => setState(() => _parent = v),
          ),
          if (isFolder && _error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _delete,
                  icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                  label: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(onPressed: _save, child: const Text('Save')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
