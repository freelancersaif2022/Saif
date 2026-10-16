import 'dart:async';

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/archive_api.dart';
import '../services/connectivity.dart';
import '../widgets/feedback.dart';

/// Bottom sheet that searches any city, street or landmark by name.
Future<PlaceResult?> showPlaceSearch(BuildContext context, ArchiveApi api) {
  if (!ConnectivityService.instance.online) {
    showToast('No internet connection', kind: ToastKind.offline, message: 'Searching places needs a connection.');
    return Future.value(null);
  }
  return showModalBottomSheet<PlaceResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: GC.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _SearchSheet(api: api),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.api});
  final ArchiveApi api;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<PlaceResult> _results = const [];
  bool _loading = false;
  String? _error;
  int _token = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    // OpenStreetMap search allows about one request per second.
    _debounce = Timer(const Duration(milliseconds: 650), () => _run(q));
    setState(() {});
  }

  Future<void> _run(String q) async {
    q = q.trim();
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }
    final token = ++_token;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.api.searchPlaces(q);
      if (!mounted || token != _token) return;
      setState(() => _results = r);
    } on ApiException catch (e) {
      if (!mounted || token != _token) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted && token == _token) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
              child: Text('Search any place', style: GC.display(24)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              child: Text('A city, street, landmark or address.', style: GC.body(14, color: GC.muted)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                onSubmitted: _run,
                textInputAction: TextInputAction.search,
                style: GC.body(16, color: GC.text, height: 1.3),
                cursorColor: GC.amber,
                decoration: InputDecoration(
                  hintText: 'e.g. Anarkali Bazaar, Lahore',
                  hintStyle: GC.body(15, color: GC.faint, height: 1.3),
                  prefixIcon: const Icon(Icons.search_rounded, color: GC.muted),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: GC.amber)),
                        )
                      : (_controller.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.close_rounded, color: GC.muted),
                              onPressed: () {
                                _controller.clear();
                                _onChanged('');
                              },
                            )),
                  filled: true,
                  fillColor: GC.surface2,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GC.radiusM), borderSide: const BorderSide(color: GC.line)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GC.radiusM), borderSide: const BorderSide(color: GC.amber)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center, style: GC.body(14.5, color: GC.coral)),
                      ),
                    )
                  : (_results.isEmpty
                      ? Center(
                          child: Text(
                            _controller.text.trim().length < 2 ? 'Start typing to search' : (_loading ? '' : 'No places found'),
                            style: GC.body(14.5, color: GC.faint),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, indent: 64, color: GC.line),
                          itemBuilder: (_, i) {
                            final r = _results[i];
                            return ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(color: GC.amberDeep, shape: BoxShape.circle),
                                child: const Icon(Icons.place_rounded, color: GC.amber, size: 20),
                              ),
                              title: Text(r.name, style: GC.body(15.5, color: GC.text, weight: FontWeight.w700, height: 1.25)),
                              subtitle: Text(r.detail,
                                  maxLines: 2, overflow: TextOverflow.ellipsis, style: GC.body(12.5, color: GC.muted, height: 1.35)),
                              onTap: () => Navigator.of(context).pop(r),
                            );
                          },
                        )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Text('Search by OpenStreetMap Nominatim', style: GC.body(11, color: GC.faint)),
            ),
          ],
        ),
      ),
    );
  }
}
