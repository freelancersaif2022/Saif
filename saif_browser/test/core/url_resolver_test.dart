import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/core/utils/search_engines.dart';
import 'package:saif_browser/core/utils/url_resolver.dart';
import 'package:saif_browser/core/utils/user_agents.dart';

import '../support/fakes.dart';

void main() {
  group('URL navigation', () {
    test('adds https to bare domains', () {
      expect(UrlResolver.toUrl('example.com'), 'https://example.com');
      expect(UrlResolver.toUrl('news.ycombinator.com/item?id=1'), 'https://news.ycombinator.com/item?id=1');
      expect(UrlResolver.toUrl('  wikipedia.org  '), 'https://wikipedia.org');
    });

    test('keeps explicit schemes', () {
      expect(UrlResolver.toUrl('http://neverssl.com'), 'http://neverssl.com');
      expect(UrlResolver.toUrl('https://example.com/a b'), isNull, reason: 'whitespace means search');
      expect(UrlResolver.toUrl('HTTPS://Example.com/Path'), 'https://example.com/Path');
    });

    test('uses http for local hosts and IP addresses', () {
      expect(UrlResolver.toUrl('localhost:8080'), 'http://localhost:8080');
      expect(UrlResolver.toUrl('192.168.1.1'), 'http://192.168.1.1');
      expect(UrlResolver.toUrl('10.0.0.2:3000/admin'), 'http://10.0.0.2:3000/admin');
      expect(UrlResolver.toUrl('999.1.1.1'), isNull);
    });

    test('rejects dangerous or non-web schemes', () {
      expect(UrlResolver.toUrl('javascript:alert(1)'), isNull);
      expect(UrlResolver.toUrl('file:///sdcard/secret'), isNull);
      expect(UrlResolver.toUrl('mailto:a@b.com'), isNull);
    });

    test('about:blank is allowed', () {
      expect(UrlResolver.toUrl('about:blank'), 'about:blank');
    });
  });

  group('Search queries', () {
    test('plain words become a search with the default engine (Google)', () {
      expect(
        UrlResolver.resolve('flutter webview', SearchEngine.google),
        'https://www.google.com/search?q=flutter+webview',
      );
      expect(UrlResolver.resolve('weather', SearchEngine.google), 'https://www.google.com/search?q=weather');
    });

    test('query text is URL-encoded', () {
      expect(SearchEngine.duckDuckGo.searchUrl('a&b=c #1'), 'https://duckduckgo.com/?q=a%26b%3Dc+%231');
    });

    test('custom engine requires https and %s', () {
      expect(SearchEngine.isValidTemplate('https://search.example/?q=%s'), isTrue);
      expect(SearchEngine.isValidTemplate('http://search.example/?q=%s'), isFalse);
      expect(SearchEngine.isValidTemplate('https://search.example/'), isFalse);
      expect(
        SearchEngine.resolve('custom', customTemplate: 'https://s.example/?q=%s').searchUrl('x'),
        'https://s.example/?q=x',
      );
      expect(SearchEngine.resolve('custom', customTemplate: 'bad').id, 'google');
      expect(SearchEngine.resolve('unknown').id, 'google');
    });

    test('recognises search result pages for the address bar', () {
      final url = SearchEngine.google.searchUrl('saif browser');
      expect(UrlResolver.searchTermsFor(url, SearchEngine.google), 'saif browser');
      expect(UrlResolver.searchTermsFor('https://example.com/?q=x', SearchEngine.google), isNull);
    });
  });

  group('helpers', () {
    test('origins', () {
      expect(UrlResolver.originOf('https://Example.com:443/login'), 'https://example.com');
      expect(UrlResolver.originOf('http://example.com:8080/x'), 'http://example.com:8080');
      expect(UrlResolver.originOf('about:blank'), isNull);
    });

    test('display text', () {
      expect(UrlResolver.displayText('https://www.example.com/'), 'example.com');
      expect(UrlResolver.displayText('http://example.com/path'), 'example.com/path');
      expect(UrlResolver.displayText(UrlResolver.newTabUrl), '');
    });
  });

  group('User agents', () {
    test('mobile UA drops WebView markers', () {
      final ua = UserAgents.mobile(testUserAgent);
      expect(ua, isNot(contains('; wv')));
      expect(ua, isNot(contains('Version/4.0')));
      expect(ua, contains('Chrome/129.0.6668.100 Mobile Safari'));
    });

    test('desktop UA keeps the Chromium major version', () {
      final ua = UserAgents.desktop(testUserAgent);
      expect(ua, contains('X11; Linux x86_64'));
      expect(ua, contains('Chrome/129.0.0.0'));
      expect(ua, isNot(contains('Mobile')));
    });
  });
}
