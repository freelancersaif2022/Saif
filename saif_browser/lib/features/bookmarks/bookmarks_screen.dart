import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/host_favicon.dart';
import '../tabs/tabs_controller.dart';
import 'bookmark.dart';
import 'bookmark_editor.dart';

/// Browses bookmark folders, searches bookmarks and organizes them. Pops
/// with a URL when the user opens a bookmark.
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  final List<Bookmark> _path = [];
  List<Bookmark> _items = const [];
  String _query = '';
  bool _searching = false;
  bool _loading = true;

  int? get _folderId => _path.isEmpty ? null : _path.last.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(bookmarkRepositoryProvider);
    final items = _query.trim().isEmpty ? await repo.children(_folderId) : await repo.search(_query);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _addFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Folder name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Create')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    await ref.read(bookmarkRepositoryProvider).addFolder(name, parentId: _folderId);
    ref.read(dataRevisionProvider.notifier).bump();
    await _load();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final list = [..._items];
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    setState(() => _items = list);
    await ref.read(bookmarkRepositoryProvider).reorder(list.map((b) => b.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final title = _path.isEmpty ? 'Bookmarks' : _path.last.title;
    final canReorder = _query.isEmpty && _items.length > 1;
    return PopScope(
      canPop: _path.isEmpty && !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() {
          if (_searching) {
            _searching = false;
            _query = '';
          } else {
            _path.removeLast();
          }
        });
        _load();
      },
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search bookmarks',
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (v) {
                    _query = v;
                    _load();
                  },
                )
              : Text(title),
          actions: [
            if (!_searching)
              IconButton(
                tooltip: 'Search',
                onPressed: () => setState(() => _searching = true),
                icon: const Icon(Icons.search_rounded),
              ),
            if (!_searching)
              IconButton(
                tooltip: 'New folder',
                onPressed: _addFolder,
                icon: const Icon(Icons.create_new_folder_outlined),
              ),
          ],
        ),
        body: _loading
            ? const SizedBox.shrink()
            : _items.isEmpty
            ? EmptyState(
                icon: Icons.star_outline_rounded,
                title: _query.isEmpty ? 'No bookmarks here' : 'No matching bookmarks',
                message: _query.isEmpty ? 'Tap the star in the toolbar to bookmark a page.' : null,
              )
            : ReorderableListView.builder(
                buildDefaultDragHandles: canReorder,
                itemCount: _items.length,
                onReorderItem: _onReorder,
                itemBuilder: (context, i) {
                  final b = _items[i];
                  return ListTile(
                    key: ValueKey(b.id),
                    leading: b.isFolder ? const Icon(Icons.folder_outlined) : HostFavicon(url: b.url ?? '', size: 26),
                    title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: b.isFolder
                        ? null
                        : Text(UrlResolver.displayText(b.url ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      if (b.isFolder) {
                        setState(() => _path.add(b));
                        _load();
                      } else {
                        Navigator.pop(context, b.url);
                      }
                    },
                    trailing: PopupMenuButton<String>(
                      tooltip: 'More',
                      onSelected: (action) async {
                        switch (action) {
                          case 'edit':
                            await showBookmarkEditor(context, ref, bookmark: b);
                          case 'newtab':
                            ref.read(tabsProvider.notifier).newTab(url: b.url, incognito: false);
                            if (context.mounted) showMessage(context, 'Opened in new tab');
                          case 'private':
                            ref.read(tabsProvider.notifier).newTab(url: b.url, incognito: true);
                            if (context.mounted) Navigator.pop(context);
                          case 'delete':
                            await ref.read(bookmarkRepositoryProvider).delete(b.id);
                            ref.read(dataRevisionProvider.notifier).bump();
                        }
                        await _load();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        if (!b.isFolder) const PopupMenuItem(value: 'newtab', child: Text('Open in new tab')),
                        if (!b.isFolder) const PopupMenuItem(value: 'private', child: Text('Open in private tab')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
