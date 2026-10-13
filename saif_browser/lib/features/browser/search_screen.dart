import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/widgets/host_favicon.dart';
import '../history/history_entry.dart';
import '../settings/settings_controller.dart';

class _Suggestion {
  const _Suggestion(this.title, this.url, this.icon);

  final String title;
  final String url;
  final IconData icon;
}

/// Full-screen address entry with local suggestions from history and
/// bookmarks. Nothing typed here is sent anywhere until the user submits.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, required this.initialText, required this.private});

  final String initialText;
  final bool private;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText)
    ..selection = TextSelection(baseOffset: 0, extentOffset: widget.initialText.length);
  List<_Suggestion> _suggestions = const [];
  int _query = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _update(String text) async {
    final id = ++_query;
    if (text.trim().isEmpty) {
      setState(() => _suggestions = const []);
      return;
    }
    final history = widget.private
        ? const <HistoryEntry>[]
        : await ref.read(historyRepositoryProvider).suggestions(text);
    final bookmarks = await ref.read(bookmarkRepositoryProvider).search(text, limit: 4);
    if (!mounted || id != _query) return;
    final seen = <String>{};
    setState(() {
      _suggestions = [
        for (final b in bookmarks)
          if (b.url != null && seen.add(b.url!)) _Suggestion(b.title, b.url!, Icons.star_outline_rounded),
        for (final h in history)
          if (seen.add(h.url)) _Suggestion(h.title.isEmpty ? h.url : h.title, h.url, Icons.history_rounded),
      ];
    });
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    Navigator.pop(context, value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final engine = ref.watch(settingsProvider.select((s) => s.engine));
    final text = _controller.text.trim();
    final asUrl = UrlResolver.toUrl(text);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      autocorrect: false,
                      enableSuggestions: !widget.private,
                      enableIMEPersonalizedLearning: !widget.private,
                      style: const TextStyle(fontSize: 16.5),
                      decoration: InputDecoration(
                        hintText: widget.private ? 'Search privately or type URL' : 'Search or type URL',
                        suffixIcon: text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                onPressed: () {
                                  _controller.clear();
                                  _update('');
                                },
                                icon: const Icon(Icons.cancel_rounded),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: palette.accent, width: 2),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {});
                        _update(v);
                      },
                      onSubmitted: _submit,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  if (text.isNotEmpty)
                    ListTile(
                      leading: Icon(asUrl != null ? Icons.public_rounded : Icons.search_rounded),
                      title: Text(asUrl ?? text, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(asUrl != null ? 'Go to address' : 'Search with ${engine.name}'),
                      onTap: () => _submit(text),
                    ),
                  if (text.isNotEmpty && asUrl != null)
                    ListTile(
                      leading: const Icon(Icons.search_rounded),
                      title: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('Search with ${engine.name}'),
                      onTap: () => Navigator.pop(context, engine.searchUrl(text)),
                    ),
                  for (final s in _suggestions)
                    ListTile(
                      leading: HostFavicon(url: s.url, size: 22),
                      title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(UrlResolver.displayText(s.url), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        tooltip: 'Edit',
                        icon: Icon(s.icon == Icons.history_rounded ? Icons.north_west_rounded : s.icon, size: 20),
                        onPressed: () {
                          _controller.text = s.url;
                          _controller.selection = TextSelection.collapsed(offset: s.url.length);
                          setState(() {});
                          _update(s.url);
                        },
                      ),
                      onTap: () => Navigator.pop(context, s.url),
                    ),
                  if (widget.initialText.isNotEmpty && text == widget.initialText)
                    ListTile(
                      leading: const Icon(Icons.copy_rounded),
                      title: const Text('Copy link'),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.initialText));
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
