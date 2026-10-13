import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/features/tabs/page_error.dart';

PageError classify(int code, String description, {bool online = true}) =>
    PageError.fromWebView(url: 'https://example.com/', code: code, description: description, online: online);

void main() {
  test('offline is detected from the real error and connectivity', () {
    expect(classify(-2, 'net::ERR_INTERNET_DISCONNECTED').kind, PageErrorKind.offline);
    expect(classify(-2, 'net::ERR_NAME_NOT_RESOLVED', online: false).kind, PageErrorKind.offline);
    final offline = classify(-2, 'net::ERR_INTERNET_DISCONNECTED');
    expect(offline.title, 'No Internet Connection');
    expect(offline.message, 'Check your internet connection and try again.');
  });

  test('DNS failure while online is not reported as offline', () {
    expect(classify(-2, 'net::ERR_NAME_NOT_RESOLVED').kind, PageErrorKind.dns);
  });

  test('timeouts, refused connections, SSL and redirects', () {
    expect(classify(-8, 'net::ERR_TIMED_OUT').kind, PageErrorKind.timeout);
    expect(classify(-6, 'net::ERR_CONNECTION_TIMED_OUT').kind, PageErrorKind.timeout);
    expect(classify(-6, 'net::ERR_CONNECTION_REFUSED').kind, PageErrorKind.connectionRefused);
    expect(classify(-11, 'net::ERR_SSL_PROTOCOL_ERROR').kind, PageErrorKind.ssl);
    expect(classify(-9, 'net::ERR_TOO_MANY_REDIRECTS').kind, PageErrorKind.tooManyRedirects);
    expect(classify(-12, 'net::ERR_INVALID_URL').kind, PageErrorKind.invalidUrl);
    expect(classify(-16, 'net::ERR_BLOCKED_BY_CLIENT').kind, PageErrorKind.blocked);
  });

  test('proxy failures are their own category', () {
    expect(classify(-6, 'net::ERR_PROXY_CONNECTION_FAILED').kind, PageErrorKind.proxy);
    expect(classify(-1, 'net::ERR_TUNNEL_CONNECTION_FAILED').kind, PageErrorKind.proxy);
    expect(classify(-5, '').kind, PageErrorKind.proxy);
  });
}
