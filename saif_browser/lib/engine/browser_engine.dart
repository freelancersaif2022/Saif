import 'dart:async';

import 'package:flutter/services.dart';

import 'engine_event.dart';

/// Controls native WebView tabs. Implemented over a method channel on
/// Android and by a fake in tests.
abstract class BrowserEngine {
  Stream<EngineEvent> get events;

  Future<EngineInfo> init();
  Future<void> applySettings(EngineSettings settings);

  Future<void> createTab(String tabId, {required bool incognito, String? url, bool desktopMode = false});
  Future<void> disposeTab(String tabId);
  Future<void> suspendTab(String tabId);
  Future<void> setTabVisible(String tabId, bool visible);

  /// Shows [tabId]'s WebView in the browser surface (null hides all).
  Future<void> showTab(String? tabId);

  Future<void> loadUrl(String tabId, String url);

  /// URL the WebView currently shows (null when nothing is committed).
  Future<String?> currentUrl(String tabId);
  Future<void> goBack(String tabId);
  Future<void> goForward(String tabId);
  Future<void> reload(String tabId);
  Future<void> stop(String tabId);
  Future<void> setDesktopMode(String tabId, bool enabled);
  Future<void> setTextZoom(String tabId, int? percent);

  Future<void> find(String tabId, String query);
  Future<void> findNext(String tabId, {required bool forward});
  Future<void> clearFind(String tabId);

  Future<Uint8List?> captureThumbnail(String tabId, {int maxWidth = 360});
  Future<String> fillCredential(
    String tabId, {
    required String origin,
    required String username,
    required String password,
  });
  Future<String?> readBlob(String tabId, String url);
  Future<void> allowHttpHost(String host);
  Future<bool> exitFullscreen();

  Future<void> respondFileChooser(int requestId, String source);
  Future<void> respondPermission(int requestId, List<String> granted, {bool remember = false});
  Future<void> respondHttpAuth(int requestId, {String? username, String? password});
  Future<bool> requestAndroidPermissions(List<String> permissions);

  Future<void> clearBrowsingData({
    bool cookies = false,
    bool cache = false,
    bool storage = false,
    bool httpAuth = false,
    bool permissions = false,
  });

  /// Destroys private tabs and deletes the private profile. Returns true when
  /// private storage was isolated and has been removed.
  Future<bool> endIncognitoSession();

  Future<void> setProxyOverride(String proxyUrl);
  Future<bool> clearProxyOverride();
  Future<bool> isOnline();
  Future<String?> getCookies(String url, {required bool incognito});
}

class MethodChannelBrowserEngine implements BrowserEngine {
  MethodChannelBrowserEngine({MethodChannel? channel}) : _channel = channel ?? const MethodChannel('saif/engine') {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  final StreamController<EngineEvent> _events = StreamController.broadcast();

  @override
  Stream<EngineEvent> get events => _events.stream;

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method == 'onEvent' && call.arguments is Map) {
      _events.add(EngineEvent.fromMap(call.arguments as Map<Object?, Object?>));
    }
    return null;
  }

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? args]) => _channel.invokeMethod<T>(method, args);

  @override
  Future<EngineInfo> init() async {
    final map = await _invoke<Map<Object?, Object?>>('init');
    return EngineInfo.fromMap(map ?? const {});
  }

  @override
  Future<void> applySettings(EngineSettings settings) => _invoke('applySettings', settings.toMap());

  @override
  Future<void> createTab(String tabId, {required bool incognito, String? url, bool desktopMode = false}) =>
      _invoke('createTab', {'tabId': tabId, 'incognito': incognito, 'url': url, 'desktopMode': desktopMode});

  @override
  Future<void> disposeTab(String tabId) => _invoke('disposeTab', {'tabId': tabId});

  @override
  Future<void> suspendTab(String tabId) => _invoke('suspendTab', {'tabId': tabId});

  @override
  Future<void> setTabVisible(String tabId, bool visible) =>
      _invoke('setTabVisible', {'tabId': tabId, 'visible': visible});

  @override
  Future<void> showTab(String? tabId) => _invoke('showTab', {'tabId': tabId});

  @override
  Future<void> loadUrl(String tabId, String url) => _invoke('loadUrl', {'tabId': tabId, 'url': url});

  @override
  Future<String?> currentUrl(String tabId) async {
    final state = await _invoke<Map<Object?, Object?>>('navigationState', {'tabId': tabId});
    return state?['url'] as String?;
  }

  @override
  Future<void> goBack(String tabId) => _invoke('goBack', {'tabId': tabId});

  @override
  Future<void> goForward(String tabId) => _invoke('goForward', {'tabId': tabId});

  @override
  Future<void> reload(String tabId) => _invoke('reload', {'tabId': tabId});

  @override
  Future<void> stop(String tabId) => _invoke('stop', {'tabId': tabId});

  @override
  Future<void> setDesktopMode(String tabId, bool enabled) =>
      _invoke('setDesktopMode', {'tabId': tabId, 'enabled': enabled});

  @override
  Future<void> setTextZoom(String tabId, int? percent) => _invoke('setTextZoom', {'tabId': tabId, 'percent': percent});

  @override
  Future<void> find(String tabId, String query) => _invoke('find', {'tabId': tabId, 'query': query});

  @override
  Future<void> findNext(String tabId, {required bool forward}) =>
      _invoke('findNext', {'tabId': tabId, 'forward': forward});

  @override
  Future<void> clearFind(String tabId) => _invoke('clearFind', {'tabId': tabId});

  @override
  Future<Uint8List?> captureThumbnail(String tabId, {int maxWidth = 360}) =>
      _invoke<Uint8List>('captureThumbnail', {'tabId': tabId, 'maxWidth': maxWidth});

  @override
  Future<String> fillCredential(
    String tabId, {
    required String origin,
    required String username,
    required String password,
  }) async {
    final status = await _invoke<String>('fillCredential', {
      'tabId': tabId,
      'origin': origin,
      'username': username,
      'password': password,
    });
    return status ?? 'error';
  }

  @override
  Future<String?> readBlob(String tabId, String url) => _invoke<String>('readBlob', {'tabId': tabId, 'url': url});

  @override
  Future<void> allowHttpHost(String host) => _invoke('allowHttpHost', {'host': host});

  @override
  Future<bool> exitFullscreen() async => await _invoke<bool>('exitFullscreen') ?? false;

  @override
  Future<void> respondFileChooser(int requestId, String source) =>
      _invoke('respondFileChooser', {'requestId': requestId, 'source': source});

  @override
  Future<void> respondPermission(int requestId, List<String> granted, {bool remember = false}) =>
      _invoke('respondPermission', {'requestId': requestId, 'granted': granted, 'remember': remember});

  @override
  Future<void> respondHttpAuth(int requestId, {String? username, String? password}) =>
      _invoke('respondHttpAuth', {'requestId': requestId, 'username': username, 'password': password});

  @override
  Future<bool> requestAndroidPermissions(List<String> permissions) async =>
      await _invoke<bool>('requestAndroidPermissions', {'permissions': permissions}) ?? false;

  @override
  Future<void> clearBrowsingData({
    bool cookies = false,
    bool cache = false,
    bool storage = false,
    bool httpAuth = false,
    bool permissions = false,
  }) => _invoke('clearBrowsingData', {
    'cookies': cookies,
    'cache': cache,
    'storage': storage,
    'httpAuth': httpAuth,
    'permissions': permissions,
  });

  @override
  Future<bool> endIncognitoSession() async {
    final result = await _invoke<Map<Object?, Object?>>('endIncognitoSession');
    return result?['isolated'] == true;
  }

  @override
  Future<void> setProxyOverride(String proxyUrl) => _invoke('setProxyOverride', {'proxyUrl': proxyUrl});

  @override
  Future<bool> clearProxyOverride() async => await _invoke<bool>('clearProxyOverride') ?? false;

  @override
  Future<bool> isOnline() async => await _invoke<bool>('isOnline') ?? true;

  @override
  Future<String?> getCookies(String url, {required bool incognito}) =>
      _invoke<String>('getCookies', {'url': url, 'incognito': incognito});
}
