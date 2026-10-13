import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/host_favicon.dart';
import '../history/history_entry.dart';
import '../settings/settings_controller.dart';
import 'search_suggestions.dart';

enum _Kind { search, bookmark, history }

class _Suggestion {
  const _Suggestion(this.title, this.value, this.kind, {this.subtitle});

  final String title;

  /// URL for bookmarks/history, query text for searches.
  final String value;
  final _Kind kind;
  final String? subtitle;
}

/// Full-screen address entry. Suggestions update as you type: query
/// suggestions from the search engine (when enabled), then matching
/// bookmarks and history from this device.
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
  List<_Suggestion> _queries = const [];
  List<_Suggestion> _local = const [];
  int _generation = 0;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {});
    final id = ++_generation;
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() {
        _queries = const [];
        _local = const [];
      });
      return;
    }
    unawaited(_loadLocal(text, id));
    _debounce = Timer(const Duration(milliseconds: 120), () => _loadQueries(text, id));
  }

  Future<void> _loadLocal(String text, int id) async {
    final history = widget.private
        ? const <HistoryEntry>[]
        : await ref.read(historyRepositoryProvider).suggestions(text, limit: 5);
    final bookmarks = await ref.read(bookmarkRepositoryProvider).search(text, limit: 3);
    if (!mounted || id != _generation) return;
    final seen = <String>{};
    setState(() {
      _local = [
        for (final b in bookmarks)
          if (b.url != null && seen.add(b.url!))
            _Suggestion(b.title, b.url!, _Kind.bookmark, subtitle: UrlResolver.displayText(b.url!)),
        for (final h in history)
          if (seen.add(h.url))
            _Suggestion(
              h.title.isEmpty ? UrlResolver.displayText(h.url) : h.title,
              h.url,
              _Kind.history,
              subtitle: UrlResolver.displayText(h.url),
            ),
      ];
    });
  }

  Future<void> _loadQueries(String text, int id) async {
    if (UrlResolver.toUrl(text) != null && text.contains('/')) return;
    final service = ref.read(searchSuggestionServiceProvider);
    if (service == null) return;
    final results = await service.fetch(ref.read(settingsProvider).engine, text);
    if (!mounted || id != _generation) return;
    setState(() {
      _queries = [
        for (final q in results)
          if (q.toLowerCase() != text.trim().toLowerCase()) _Suggestion(q, q, _Kind.search),
      ];
    });
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    Navigator.pop(context, value.trim());
  }

  void _fill(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    _onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final engine = ref.watch(settingsProvider.select((s) => s.engine));
    final text = _controller.text.trim();
    final asUrl = UrlResolver.toUrl(text);
    final showingCurrent = widget.initialText.isNotEmpty && text == widget.initialText;
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
                        prefixIcon: Icon(widget.private ? Icons.visibility_off_outlined : Icons.search_rounded),
                        suffixIcon: text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                onPressed: () {
                                  _controller.clear();
                                  _onChanged('');
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
                      onChanged: _onChanged,
                      onSubmitted: _submit,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  if (showingCurrent) _CurrentPage(url: widget.initialText),
                  if (text.isNotEmpty && !showingCurrent) ...[
                    _Row(
                      leading: Icon(asUrl != null ? Icons.public_rounded : Icons.search_rounded),
                      title: asUrl ?? text,
                      subtitle: asUrl != null ? 'Go to address' : '${engine.name} search',
                      bold: true,
                      onTap: () => _submit(text),
                    ),
                    if (asUrl != null)
                      _Row(
                        leading: const Icon(Icons.search_rounded),
                        title: text,
                        subtitle: '${engine.name} search',
                        onTap: () => Navigator.pop(context, engine.searchUrl(text)),
                      ),
                    for (final s in _queries)
                      _Row(
                        leading: const Icon(Icons.search_rounded),
                        title: s.title,
                        highlight: text,
                        onTap: () => _submit(s.value),
                        trailing: IconButton(
                          tooltip: 'Use “${s.title}”',
                          icon: const Icon(Icons.north_west_rounded, size: 20),
                          onPressed: () => _fill(s.value),
                        ),
                      ),
                    if (_local.isNotEmpty && _queries.isNotEmpty) const Divider(indent: 20, endIndent: 20),
                    for (final s in _local)
                      _Row(
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            HostFavicon(url: s.value, size: 24),
                            Positioned(
                              right: -6,
                              bottom: -6,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(color: palette.surface, shape: BoxShape.circle),
                                child: Icon(
                                  s.kind == _Kind.bookmark ? Icons.star_rounded : Icons.history_rounded,
                                  size: 11,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: s.title,
                        subtitle: s.subtitle,
                        highlight: text,
                        onTap: () => Navigator.pop(context, s.value),
                        trailing: IconButton(
                          tooltip: 'Edit address',
                          icon: const Icon(Icons.north_west_rounded, size: 20),
                          onPressed: () => _fill(s.value),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentPage extends ConsumerWidget {
  const _CurrentPage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          HostFavicon(url: url, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UrlResolver.hostOf(url) ?? url, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy link',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              showMessage(context, 'Link copied', icon: Icons.link_rounded);
            },
            icon: const Icon(Icons.copy_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () => ref.read(systemBridgeProvider).shareText(url),
            icon: const Icon(Icons.share_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.highlight,
    this.bold = false,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? highlight;
  final bool bold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final base = TextStyle(
      fontSize: 15.5,
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
    );
    return ListTile(
      leading: SizedBox(width: 28, child: Center(child: leading)),
      minLeadingWidth: 28,
      title: Text.rich(_highlighted(title, highlight, base), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textSecondary),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// Shows the typed text normally and the completion in bold, like Chrome.
  static TextSpan _highlighted(String text, String? typed, TextStyle base) {
    final t = typed?.trim().toLowerCase() ?? '';
    final index = t.isEmpty ? -1 : text.toLowerCase().indexOf(t);
    if (index < 0) return TextSpan(text: text, style: base);
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    return TextSpan(
      children: [
        if (index > 0) TextSpan(text: text.substring(0, index), style: bold),
        TextSpan(text: text.substring(index, index + t.length), style: base),
        TextSpan(text: text.substring(index + t.length), style: bold),
      ],
    );
  }
}
