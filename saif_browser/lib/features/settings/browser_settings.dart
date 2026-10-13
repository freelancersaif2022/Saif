import 'package:flutter/material.dart';

import '../../core/utils/search_engines.dart';

enum ToolbarPosition { top, bottom }

enum UserAgentMode { chrome, webview, custom }

enum DownloadLocation { downloads, ask }

/// Every user preference. Stored locally as JSON in SharedPreferences.
@immutable
class BrowserSettings {
  const BrowserSettings({
    this.themeMode = ThemeMode.light,
    this.accent = 'lime',
    this.toolbarPosition = ToolbarPosition.top,
    this.textZoom = 100,
    this.searchEngine = 'google',
    this.customSearchTemplate = '',
    this.homepage = '',
    this.javaScriptEnabled = true,
    this.desktopModeDefault = false,
    this.blockPopups = true,
    this.acceptCookies = true,
    this.thirdPartyCookies = false,
    this.userAgentMode = UserAgentMode.chrome,
    this.customUserAgent = '',
    this.httpsFirst = true,
    this.safeBrowsing = true,
    this.restoreTabs = true,
    this.blockPrivateScreenshots = true,
    this.askBeforeDownload = true,
    this.downloadLocation = DownloadLocation.downloads,
    this.openWhenComplete = false,
    this.requireAuthForPasswords = true,
    this.searchSuggestions = true,
    this.offerToSavePasswords = true,
  });

  final ThemeMode themeMode;
  final String accent;
  final ToolbarPosition toolbarPosition;
  final int textZoom;
  final String searchEngine;
  final String customSearchTemplate;

  /// Empty means the new tab page.
  final String homepage;
  final bool javaScriptEnabled;
  final bool desktopModeDefault;
  final bool blockPopups;
  final bool acceptCookies;
  final bool thirdPartyCookies;
  final UserAgentMode userAgentMode;
  final String customUserAgent;
  final bool httpsFirst;
  final bool safeBrowsing;
  final bool restoreTabs;
  final bool blockPrivateScreenshots;
  final bool askBeforeDownload;
  final DownloadLocation downloadLocation;
  final bool openWhenComplete;
  final bool requireAuthForPasswords;

  /// Ask the search engine for query suggestions while typing.
  final bool searchSuggestions;

  /// Offer to save passwords after signing in to a site.
  final bool offerToSavePasswords;

  SearchEngine get engine => SearchEngine.resolve(searchEngine, customTemplate: customSearchTemplate);

  BrowserSettings copyWith({
    ThemeMode? themeMode,
    String? accent,
    ToolbarPosition? toolbarPosition,
    int? textZoom,
    String? searchEngine,
    String? customSearchTemplate,
    String? homepage,
    bool? javaScriptEnabled,
    bool? desktopModeDefault,
    bool? blockPopups,
    bool? acceptCookies,
    bool? thirdPartyCookies,
    UserAgentMode? userAgentMode,
    String? customUserAgent,
    bool? httpsFirst,
    bool? safeBrowsing,
    bool? restoreTabs,
    bool? blockPrivateScreenshots,
    bool? askBeforeDownload,
    DownloadLocation? downloadLocation,
    bool? openWhenComplete,
    bool? requireAuthForPasswords,
    bool? searchSuggestions,
    bool? offerToSavePasswords,
  }) {
    return BrowserSettings(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      toolbarPosition: toolbarPosition ?? this.toolbarPosition,
      textZoom: textZoom ?? this.textZoom,
      searchEngine: searchEngine ?? this.searchEngine,
      customSearchTemplate: customSearchTemplate ?? this.customSearchTemplate,
      homepage: homepage ?? this.homepage,
      javaScriptEnabled: javaScriptEnabled ?? this.javaScriptEnabled,
      desktopModeDefault: desktopModeDefault ?? this.desktopModeDefault,
      blockPopups: blockPopups ?? this.blockPopups,
      acceptCookies: acceptCookies ?? this.acceptCookies,
      thirdPartyCookies: thirdPartyCookies ?? this.thirdPartyCookies,
      userAgentMode: userAgentMode ?? this.userAgentMode,
      customUserAgent: customUserAgent ?? this.customUserAgent,
      httpsFirst: httpsFirst ?? this.httpsFirst,
      safeBrowsing: safeBrowsing ?? this.safeBrowsing,
      restoreTabs: restoreTabs ?? this.restoreTabs,
      blockPrivateScreenshots: blockPrivateScreenshots ?? this.blockPrivateScreenshots,
      askBeforeDownload: askBeforeDownload ?? this.askBeforeDownload,
      downloadLocation: downloadLocation ?? this.downloadLocation,
      openWhenComplete: openWhenComplete ?? this.openWhenComplete,
      requireAuthForPasswords: requireAuthForPasswords ?? this.requireAuthForPasswords,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      offerToSavePasswords: offerToSavePasswords ?? this.offerToSavePasswords,
    );
  }

  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'accent': accent,
    'toolbarPosition': toolbarPosition.name,
    'textZoom': textZoom,
    'searchEngine': searchEngine,
    'customSearchTemplate': customSearchTemplate,
    'homepage': homepage,
    'javaScriptEnabled': javaScriptEnabled,
    'desktopModeDefault': desktopModeDefault,
    'blockPopups': blockPopups,
    'acceptCookies': acceptCookies,
    'thirdPartyCookies': thirdPartyCookies,
    'userAgentMode': userAgentMode.name,
    'customUserAgent': customUserAgent,
    'httpsFirst': httpsFirst,
    'safeBrowsing': safeBrowsing,
    'restoreTabs': restoreTabs,
    'blockPrivateScreenshots': blockPrivateScreenshots,
    'askBeforeDownload': askBeforeDownload,
    'downloadLocation': downloadLocation.name,
    'openWhenComplete': openWhenComplete,
    'requireAuthForPasswords': requireAuthForPasswords,
    'searchSuggestions': searchSuggestions,
    'offerToSavePasswords': offerToSavePasswords,
  };

  /// Reads settings, falling back to defaults for missing or invalid values.
  factory BrowserSettings.fromJson(Map<String, Object?> json) {
    const d = BrowserSettings();
    T pick<T>(String key, T fallback) {
      final value = json[key];
      return value is T ? value : fallback;
    }

    E pickEnum<E extends Enum>(List<E> values, String key, E fallback) {
      final name = json[key];
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return BrowserSettings(
      themeMode: pickEnum(ThemeMode.values, 'themeMode', d.themeMode),
      accent: pick('accent', d.accent),
      toolbarPosition: pickEnum(ToolbarPosition.values, 'toolbarPosition', d.toolbarPosition),
      textZoom: pick<num>('textZoom', d.textZoom).toInt().clamp(50, 300),
      searchEngine: pick('searchEngine', d.searchEngine),
      customSearchTemplate: pick('customSearchTemplate', d.customSearchTemplate),
      homepage: pick('homepage', d.homepage),
      javaScriptEnabled: pick('javaScriptEnabled', d.javaScriptEnabled),
      desktopModeDefault: pick('desktopModeDefault', d.desktopModeDefault),
      blockPopups: pick('blockPopups', d.blockPopups),
      acceptCookies: pick('acceptCookies', d.acceptCookies),
      thirdPartyCookies: pick('thirdPartyCookies', d.thirdPartyCookies),
      userAgentMode: pickEnum(UserAgentMode.values, 'userAgentMode', d.userAgentMode),
      customUserAgent: pick('customUserAgent', d.customUserAgent),
      httpsFirst: pick('httpsFirst', d.httpsFirst),
      safeBrowsing: pick('safeBrowsing', d.safeBrowsing),
      restoreTabs: pick('restoreTabs', d.restoreTabs),
      blockPrivateScreenshots: pick('blockPrivateScreenshots', d.blockPrivateScreenshots),
      askBeforeDownload: pick('askBeforeDownload', d.askBeforeDownload),
      downloadLocation: pickEnum(DownloadLocation.values, 'downloadLocation', d.downloadLocation),
      openWhenComplete: pick('openWhenComplete', d.openWhenComplete),
      requireAuthForPasswords: pick('requireAuthForPasswords', d.requireAuthForPasswords),
      searchSuggestions: pick('searchSuggestions', d.searchSuggestions),
      offerToSavePasswords: pick('offerToSavePasswords', d.offerToSavePasswords),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! BrowserSettings) return false;
    final a = toJson();
    final b = other.toJson();
    return a.keys.every((k) => a[k] == b[k]);
  }

  @override
  int get hashCode => Object.hashAll(toJson().values);
}
