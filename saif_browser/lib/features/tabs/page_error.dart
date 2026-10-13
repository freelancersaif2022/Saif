import 'package:flutter/foundation.dart';

enum PageErrorKind {
  offline,
  dns,
  timeout,
  connectionRefused,
  connectionFailed,
  ssl,
  invalidUrl,
  unsupportedScheme,
  blocked,
  tooManyRedirects,
  proxy,
  crashed,
  insecure,
  unknown,
}

/// A main-frame navigation failure, classified from real WebView errors.
@immutable
class PageError {
  const PageError({required this.kind, required this.url, this.code, this.description, this.detail});

  final PageErrorKind kind;
  final String url;

  /// WebViewClient ERROR_* code.
  final int? code;

  /// Chromium net error, e.g. `net::ERR_NAME_NOT_RESOLVED`.
  final String? description;

  /// Extra information such as the proxy failure reason.
  final String? detail;

  // android.webkit.WebViewClient error codes.
  static const errorUnknown = -1;
  static const errorHostLookup = -2;
  static const errorUnsupportedAuthScheme = -3;
  static const errorAuthentication = -4;
  static const errorProxyAuthentication = -5;
  static const errorConnect = -6;
  static const errorIo = -7;
  static const errorTimeout = -8;
  static const errorRedirectLoop = -9;
  static const errorUnsupportedScheme = -10;
  static const errorFailedSslHandshake = -11;
  static const errorBadUrl = -12;
  static const errorFile = -13;
  static const errorFileNotFound = -14;
  static const errorTooManyRequests = -15;
  static const errorUnsafeResource = -16;

  /// Classifies a WebView `onReceivedError` callback. [online] comes from
  /// Android's ConnectivityManager at the time of the error.
  factory PageError.fromWebView({required String url, required int code, String? description, required bool online}) {
    final d = (description ?? '').toUpperCase();
    PageErrorKind kind;
    if (d.contains('ERR_INTERNET_DISCONNECTED') || (d.contains('ERR_NETWORK_CHANGED') && !online)) {
      kind = PageErrorKind.offline;
    } else if (d.contains('ERR_PROXY') ||
        d.contains('ERR_TUNNEL_CONNECTION_FAILED') ||
        code == errorProxyAuthentication) {
      kind = PageErrorKind.proxy;
    } else if (!online &&
        (code == errorHostLookup || code == errorConnect || code == errorTimeout || code == errorIo)) {
      kind = PageErrorKind.offline;
    } else if (d.contains('ERR_NAME_NOT_RESOLVED') ||
        d.contains('ERR_NAME_RESOLUTION_FAILED') ||
        code == errorHostLookup) {
      kind = PageErrorKind.dns;
    } else if (d.contains('TIMED_OUT') || code == errorTimeout) {
      kind = PageErrorKind.timeout;
    } else if (d.contains('ERR_CONNECTION_REFUSED')) {
      kind = PageErrorKind.connectionRefused;
    } else if (d.contains('ERR_CERT') || d.contains('ERR_SSL') || code == errorFailedSslHandshake) {
      kind = PageErrorKind.ssl;
    } else if (d.contains('ERR_INVALID_URL') || code == errorBadUrl) {
      kind = PageErrorKind.invalidUrl;
    } else if (d.contains('ERR_UNKNOWN_URL_SCHEME') || code == errorUnsupportedScheme) {
      kind = PageErrorKind.unsupportedScheme;
    } else if (d.contains('ERR_BLOCKED') || code == errorUnsafeResource) {
      kind = PageErrorKind.blocked;
    } else if (d.contains('ERR_TOO_MANY_REDIRECTS') || code == errorRedirectLoop) {
      kind = PageErrorKind.tooManyRedirects;
    } else if (code == errorConnect || code == errorIo || d.contains('ERR_CONNECTION')) {
      kind = PageErrorKind.connectionFailed;
    } else {
      kind = PageErrorKind.unknown;
    }
    return PageError(kind: kind, url: url, code: code, description: description);
  }

  String get host => Uri.tryParse(url)?.host ?? url;

  String get title => switch (kind) {
    PageErrorKind.offline => 'No Internet Connection',
    PageErrorKind.dns => 'This site can’t be reached',
    PageErrorKind.timeout => 'The connection timed out',
    PageErrorKind.connectionRefused => 'Connection refused',
    PageErrorKind.connectionFailed => 'This site can’t be reached',
    PageErrorKind.ssl => 'Your connection is not private',
    PageErrorKind.invalidUrl => 'Invalid web address',
    PageErrorKind.unsupportedScheme => 'This link can’t be opened',
    PageErrorKind.blocked => 'This page has been blocked',
    PageErrorKind.tooManyRedirects => 'This page isn’t working',
    PageErrorKind.proxy => 'Proxy connection failed',
    PageErrorKind.crashed => 'This page crashed',
    PageErrorKind.insecure => 'Connection is not secure',
    PageErrorKind.unknown => 'This page couldn’t load',
  };

  String get message => switch (kind) {
    PageErrorKind.offline => 'Check your internet connection and try again.',
    PageErrorKind.dns => '$host’s server address could not be found. Check the spelling or try again later.',
    PageErrorKind.timeout => '$host took too long to respond.',
    PageErrorKind.connectionRefused => '$host refused to connect.',
    PageErrorKind.connectionFailed => 'The connection to $host was interrupted.',
    PageErrorKind.ssl =>
      'The certificate of $host could not be verified. Attackers might be trying to steal your information. '
          'This browser never bypasses certificate errors.',
    PageErrorKind.invalidUrl => 'The address you entered is not valid.',
    PageErrorKind.unsupportedScheme => 'The page tried to open an address the browser can’t handle.',
    PageErrorKind.blocked => 'The page was blocked because it may be unsafe.',
    PageErrorKind.tooManyRedirects => '$host redirected you too many times.',
    PageErrorKind.proxy => detail ?? 'The browser could not connect through the configured proxy server.',
    PageErrorKind.crashed => 'Something went wrong while displaying this page.',
    PageErrorKind.insecure =>
      '$host doesn’t support a secure connection (HTTPS). Information you send could be read by others on the network.',
    PageErrorKind.unknown => 'Something went wrong while loading $host.',
  };
}
