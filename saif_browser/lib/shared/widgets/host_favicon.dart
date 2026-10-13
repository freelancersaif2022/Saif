import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/url_resolver.dart';
import 'favicon_view.dart';

/// Favicon of a site from the local favicon store.
class HostFavicon extends ConsumerStatefulWidget {
  const HostFavicon({super.key, required this.url, this.size = 24});

  final String url;
  final double size;

  @override
  ConsumerState<HostFavicon> createState() => _HostFaviconState();
}

class _HostFaviconState extends ConsumerState<HostFavicon> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(HostFavicon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _load();
  }

  Future<void> _load() async {
    final host = UrlResolver.hostOf(widget.url);
    if (host == null) return;
    final repo = ref.read(faviconRepositoryProvider);
    final cached = repo.cached(host);
    if (cached != null) {
      setState(() => _bytes = cached);
      return;
    }
    final bytes = await repo.load(host);
    if (mounted && bytes != null) setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return FaviconView(bytes: _bytes, label: UrlResolver.hostOf(widget.url) ?? widget.url, size: widget.size);
  }
}
