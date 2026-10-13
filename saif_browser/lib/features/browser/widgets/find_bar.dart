import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../tabs/tabs_controller.dart';
import 'chrome_colors.dart';

/// Find-in-page bar backed by WebView.findAllAsync.
class FindBar extends ConsumerStatefulWidget {
  const FindBar({super.key, required this.tabId, required this.private, required this.onClose});

  final String tabId;
  final bool private;
  final VoidCallback onClose;

  @override
  ConsumerState<FindBar> createState() => _FindBarState();
}

class _FindBarState extends ConsumerState<FindBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    ref.read(browserEngineProvider).clearFind(widget.tabId);
    ref.read(findStateProvider.notifier).set(const FindState());
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChromeColors.of(context, private: widget.private);
    final engine = ref.read(browserEngineProvider);
    final result = ref.watch(findStateProvider);
    final hasQuery = _controller.text.isNotEmpty;
    return Container(
      color: colors.bar,
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: colors.foreground),
              decoration: InputDecoration(
                hintText: 'Find in page',
                isDense: true,
                fillColor: colors.pill,
                prefixIcon: Icon(Icons.search_rounded, color: colors.secondary),
                suffixText: hasQuery ? '${result.active}/${result.total}' : null,
                suffixStyle: TextStyle(color: colors.secondary),
              ),
              onChanged: (q) {
                setState(() {});
                if (q.isEmpty) {
                  engine.clearFind(widget.tabId);
                  ref.read(findStateProvider.notifier).set(const FindState());
                } else {
                  engine.find(widget.tabId, q);
                }
              },
              onSubmitted: (_) => engine.findNext(widget.tabId, forward: true),
            ),
          ),
          IconButton(
            tooltip: 'Previous match',
            onPressed: result.total > 0 ? () => engine.findNext(widget.tabId, forward: false) : null,
            icon: Icon(Icons.keyboard_arrow_up_rounded, color: colors.foreground),
          ),
          IconButton(
            tooltip: 'Next match',
            onPressed: result.total > 0 ? () => engine.findNext(widget.tabId, forward: true) : null,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.foreground),
          ),
          IconButton(
            tooltip: 'Close find',
            onPressed: _close,
            icon: Icon(Icons.close_rounded, color: colors.foreground),
          ),
        ],
      ),
    );
  }
}
