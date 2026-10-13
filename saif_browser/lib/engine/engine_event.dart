import 'dart:typed_data';

/// A callback from a tab's native WebView.
class EngineEvent {
  const EngineEvent(this.tabId, this.type, this.data);

  factory EngineEvent.fromMap(Map<Object?, Object?> map) {
    final data = <String, Object?>{};
    map.forEach((key, value) {
      if (key is String) data[key] = value;
    });
    return EngineEvent(data['tabId'] as String? ?? '', data['type'] as String? ?? '', data);
  }

  final String tabId;
  final String type;
  final Map<String, Object?> data;

  String? str(String key) => data[key] as String?;
  int? integer(String key) => (data[key] as num?)?.toInt();
  bool flag(String key) => data[key] == true;
  Uint8List? bytes(String key) => data[key] as Uint8List?;
  List<String> strings(String key) => (data[key] as List<Object?>?)?.whereType<String>().toList() ?? const [];

  @override
  String toString() => 'EngineEvent($type, tab: $tabId)';
}

/// Static facts about the device WebView reported at startup.
class EngineInfo {
  const EngineInfo({
    required this.defaultUserAgent,
    required this.multiProfile,
    required this.proxyOverride,
    this.webViewPackage,
    this.webViewVersion,
    this.appVersion,
    this.sdkInt = 0,
  });

  factory EngineInfo.fromMap(Map<Object?, Object?> map) => EngineInfo(
    defaultUserAgent: map['defaultUserAgent'] as String? ?? '',
    multiProfile: map['multiProfile'] == true,
    proxyOverride: map['proxyOverride'] == true,
    webViewPackage: map['webViewPackage'] as String?,
    webViewVersion: map['webViewVersion'] as String?,
    appVersion: map['appVersion'] as String?,
    sdkInt: (map['sdkInt'] as num?)?.toInt() ?? 0,
  );

  final String defaultUserAgent;

  /// Private tabs get an isolated WebView profile (cookies, storage, cache).
  final bool multiProfile;

  /// WebView supports routing traffic through a proxy.
  final bool proxyOverride;
  final String? webViewPackage;
  final String? webViewVersion;
  final String? appVersion;
  final int sdkInt;
}

/// WebView-wide settings pushed to the native engine.
class EngineSettings {
  const EngineSettings({
    required this.javaScriptEnabled,
    required this.blockPopups,
    required this.acceptCookies,
    required this.thirdPartyCookies,
    required this.textZoom,
    required this.mobileUserAgent,
    required this.desktopUserAgent,
    required this.safeBrowsing,
    required this.httpsFirst,
    this.capturePasswords = true,
  });

  final bool javaScriptEnabled;
  final bool blockPopups;
  final bool acceptCookies;
  final bool thirdPartyCookies;
  final int textZoom;
  final String mobileUserAgent;
  final String desktopUserAgent;
  final bool safeBrowsing;
  final bool httpsFirst;

  /// Offer to save passwords submitted on regular-tab pages.
  final bool capturePasswords;

  Map<String, Object?> toMap() => {
    'javaScriptEnabled': javaScriptEnabled,
    'blockPopups': blockPopups,
    'acceptCookies': acceptCookies,
    'thirdPartyCookies': thirdPartyCookies,
    'textZoom': textZoom,
    'mobileUserAgent': mobileUserAgent,
    'desktopUserAgent': desktopUserAgent,
    'safeBrowsing': safeBrowsing,
    'httpsFirst': httpsFirst,
    'capturePasswords': capturePasswords,
  };

  @override
  bool operator ==(Object other) => other is EngineSettings && _mapEquals(toMap(), other.toMap());

  @override
  int get hashCode => Object.hashAll(toMap().values);

  static bool _mapEquals(Map<String, Object?> a, Map<String, Object?> b) =>
      a.length == b.length && a.keys.every((k) => a[k] == b[k]);
}
