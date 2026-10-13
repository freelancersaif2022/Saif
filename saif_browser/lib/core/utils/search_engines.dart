/// Search providers. Queries go only to the engine the user selected.
class SearchEngine {
  const SearchEngine(this.id, this.name, this.template);

  final String id;
  final String name;

  /// URL template where `%s` is replaced by the encoded query.
  final String template;

  String searchUrl(String query) => template.replaceAll('%s', Uri.encodeQueryComponent(query.trim()));

  String get host => Uri.parse(template.replaceAll('%s', '')).host;

  static const google = SearchEngine('google', 'Google', 'https://www.google.com/search?q=%s');
  static const duckDuckGo = SearchEngine('duckduckgo', 'DuckDuckGo', 'https://duckduckgo.com/?q=%s');
  static const bing = SearchEngine('bing', 'Bing', 'https://www.bing.com/search?q=%s');
  static const brave = SearchEngine('brave', 'Brave Search', 'https://search.brave.com/search?q=%s');
  static const ecosia = SearchEngine('ecosia', 'Ecosia', 'https://www.ecosia.org/search?q=%s');
  static const startpage = SearchEngine('startpage', 'Startpage', 'https://www.startpage.com/do/search?q=%s');

  static const builtIn = [google, duckDuckGo, bing, brave, ecosia, startpage];

  /// Resolves the configured engine; `custom` uses [customTemplate] when valid.
  static SearchEngine resolve(String id, {String? customTemplate}) {
    if (id == 'custom' && isValidTemplate(customTemplate)) {
      return SearchEngine('custom', 'Custom', customTemplate!.trim());
    }
    return builtIn.firstWhere((e) => e.id == id, orElse: () => google);
  }

  static bool isValidTemplate(String? template) {
    if (template == null) return false;
    final t = template.trim();
    if (!t.contains('%s')) return false;
    final uri = Uri.tryParse(t.replaceAll('%s', 'q'));
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}
