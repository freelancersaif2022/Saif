import 'search_engines.dart';

/// Turns address-bar input into a URL: either a web address or a search.
abstract final class UrlResolver {
  static final RegExp _scheme = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*):');
  static final RegExp _ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
  static final RegExp _label = RegExp(r'^[a-zA-Z0-9¡-￿]([a-zA-Z0-9¡-￿-]*[a-zA-Z0-9¡-￿])?$');
  static final RegExp _tld = RegExp(r'^([a-zA-Z¡-￿]{2,63}|xn--[a-zA-Z0-9-]{1,59})$');

  /// Internal address of the new tab page.
  static const newTabUrl = 'about:newtab';

  /// Returns a navigable URL for [input], or a search URL when it is not one.
  static String resolve(String input, SearchEngine engine) {
    return toUrl(input) ?? engine.searchUrl(input);
  }

  /// Returns a URL when [input] is an address, otherwise null.
  static String? toUrl(String input) {
    final text = input.trim();
    if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;

    final schemeMatch = _scheme.firstMatch(text);
    if (schemeMatch != null) {
      final scheme = schemeMatch.group(1)!.toLowerCase();
      if (scheme == 'http' || scheme == 'https') {
        final uri = Uri.tryParse(text);
        if (uri == null || uri.host.isEmpty) return null;
        return uri.toString();
      }
      if (text.toLowerCase() == 'about:blank') return 'about:blank';
      // "localhost:8080" and "example.com:443/x" parse as a scheme; fall through to host checks.
      if (!_looksLikeHostWithPort(text)) return null;
    }

    final uri = Uri.tryParse('http://$text');
    if (uri == null || uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase();
    if (!_isAddressHost(host, text)) return null;
    final local = host == 'localhost' || _ipv4.hasMatch(host) || text.startsWith('[');
    final scheme = local ? 'http' : 'https';
    return '$scheme://$text';
  }

  static bool _looksLikeHostWithPort(String text) => RegExp(r'^[^/:]+:\d{1,5}(/.*)?$').hasMatch(text);

  static bool _isAddressHost(String host, String raw) {
    if (host == 'localhost') return true;
    final ip = _ipv4.firstMatch(host);
    if (ip != null) {
      return [1, 2, 3, 4].every((i) => int.parse(ip.group(i)!) <= 255);
    }
    if (raw.startsWith('[')) return true; // IPv6 literal
    final labels = host.split('.');
    if (labels.length < 2 || labels.any((l) => l.isEmpty)) return false;
    if (!labels.every(_label.hasMatch)) return false;
    return _tld.hasMatch(labels.last);
  }

  /// True for URLs the WebView should load (as opposed to internal pages).
  static bool isWebUrl(String? url) {
    if (url == null) return false;
    final lower = url.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  static bool isSecure(String? url) => url != null && url.toLowerCase().startsWith('https://');

  static String? hostOf(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    return uri.host.toLowerCase();
  }

  /// Origin (`scheme://host[:port]`) of a web URL, or null.
  static String? originOf(String? url) {
    if (!isWebUrl(url)) return null;
    final uri = Uri.tryParse(url!);
    if (uri == null || uri.host.isEmpty) return null;
    final scheme = uri.scheme.toLowerCase();
    final defaultPort = scheme == 'https' ? 443 : 80;
    final port = uri.hasPort && uri.port != defaultPort ? ':${uri.port}' : '';
    return '$scheme://${uri.host.toLowerCase()}$port';
  }

  /// Compact text for the address bar when not editing.
  static String displayText(String url) {
    if (url == newTabUrl) return '';
    var text = url;
    final lower = text.toLowerCase();
    if (lower.startsWith('https://')) {
      text = text.substring(8);
    } else if (lower.startsWith('http://')) {
      text = text.substring(7);
    }
    if (text.toLowerCase().startsWith('www.')) text = text.substring(4);
    if (text.endsWith('/') && text.indexOf('/') == text.length - 1) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  /// Extracts the search terms if [url] is a results page of [engine].
  static String? searchTermsFor(String url, SearchEngine engine) {
    final uri = Uri.tryParse(url);
    final template = Uri.tryParse(engine.template.replaceAll('%s', '__Q__'));
    if (uri == null || template == null) return null;
    if (uri.host != template.host || uri.path != template.path) return null;
    final key = template.queryParameters.entries
        .firstWhere((e) => e.value == '__Q__', orElse: () => const MapEntry('', ''))
        .key;
    if (key.isEmpty) return null;
    final q = uri.queryParameters[key];
    return (q == null || q.isEmpty) ? null : q;
  }
}
