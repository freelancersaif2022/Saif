/// Builds the user-agent strings sent by tabs.
abstract final class UserAgents {
  /// Mobile Chrome-style UA derived from the WebView default: drops the
  /// "; wv" marker and "Version/4.0" token that make some sites serve
  /// degraded pages to embedded WebViews.
  static String mobile(String webViewDefault) {
    return webViewDefault.replaceFirst('; wv)', ')').replaceFirst(RegExp(r'Version/\d+(\.\d+)* '), '').trim();
  }

  /// Desktop Chrome-style UA using the same Chromium major version.
  static String desktop(String webViewDefault) {
    final match = RegExp(r'Chrome/(\d+)').firstMatch(webViewDefault);
    final major = match?.group(1) ?? '120';
    return 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/$major.0.0.0 Safari/537.36';
  }
}
