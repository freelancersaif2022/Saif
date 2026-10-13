import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/search_engines.dart';
import '../proxy/proxy_controller.dart';
import '../proxy/proxy_models.dart';
import '../settings/settings_controller.dart';

/// Query suggestions from the selected search engine (OpenSearch JSON
/// format). Only runs while the user types in the address bar and the
/// "Search suggestions" setting is on; requests follow the proxy route.
class SearchSuggestionService {
  SearchSuggestionService({this.proxy});

  /// `host:port` of the local proxy relay, or null for direct.
  final String? proxy;

  static Uri? endpointFor(SearchEngine engine, String query) {
    final q = Uri.encodeQueryComponent(query);
    return switch (engine.id) {
      'google' => Uri.parse('https://suggestqueries.google.com/complete/search?client=firefox&q=$q'),
      'duckduckgo' => Uri.parse('https://duckduckgo.com/ac/?q=$q&type=list'),
      'bing' => Uri.parse('https://api.bing.com/osjson.aspx?query=$q'),
      'brave' => Uri.parse('https://search.brave.com/api/suggest?q=$q'),
      'ecosia' => Uri.parse('https://ac.ecosia.org/autocomplete?q=$q&type=list'),
      _ => null,
    };
  }

  /// Parses `["query", ["s1", "s2", ...], ...]`.
  static List<String> parse(String body, {int limit = 6}) {
    final json = jsonDecode(body);
    if (json is! List || json.length < 2 || json[1] is! List) return const [];
    return (json[1] as List).whereType<String>().where((s) => s.trim().isNotEmpty).take(limit).toList();
  }

  Future<List<String>> fetch(SearchEngine engine, String query) async {
    final text = query.trim();
    if (text.isEmpty || text.length > 200) return const [];
    final uri = endpointFor(engine, text);
    if (uri == null) return const [];
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    if (proxy != null) client.findProxy = (_) => 'PROXY $proxy';
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 3));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) {
        await response.drain<void>();
        return const [];
      }
      final bytes = await response.fold<List<int>>([], (a, b) => a..addAll(b)).timeout(const Duration(seconds: 3));
      return parse(utf8.decode(bytes, allowMalformed: true));
    } on Object {
      return const [];
    } finally {
      client.close(force: true);
    }
  }
}

final searchSuggestionServiceProvider = Provider<SearchSuggestionService?>((ref) {
  if (!ref.watch(settingsProvider.select((s) => s.searchSuggestions))) return null;
  String? route;
  try {
    route = ref.read(proxyControllerProvider.notifier).downloadRoute();
  } on ProxyFailure {
    return null; // proxy-only mode is blocking traffic
  }
  ref.watch(proxyControllerProvider);
  return SearchSuggestionService(proxy: route);
});
