// Test doubles hand socket and stream ownership to the code under test.
// ignore_for_file: close_sinks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:saif_browser/app/providers.dart';
import 'package:saif_browser/core/storage/app_database.dart';
import 'package:saif_browser/engine/browser_engine.dart';
import 'package:saif_browser/engine/engine_event.dart';
import 'package:saif_browser/engine/system_bridge.dart';
import 'package:saif_browser/features/passwords/vault_cipher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Records engine calls and lets tests emit WebView events.
class FakeBrowserEngine implements BrowserEngine {
  final StreamController<EngineEvent> _events = StreamController.broadcast(sync: true);
  final List<String> calls = [];
  final Set<String> created = {};
  final Set<String> suspended = {};
  final Set<String> disposed = {};
  final Map<String, String> loaded = {};
  final List<String> allowedHttpHosts = [];
  String? proxyUrl;
  bool proxySupported = true;
  int endIncognitoCalls = 0;
  EngineSettings? settings;
  Map<String, bool>? lastClear;

  void emit(String tabId, String type, [Map<String, Object?> data = const {}]) =>
      _events.add(EngineEvent(tabId, type, {...data, 'tabId': tabId, 'type': type}));

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Future<EngineInfo> init() async =>
      const EngineInfo(defaultUserAgent: testUserAgent, multiProfile: true, proxyOverride: true);

  @override
  Future<void> applySettings(EngineSettings settings) async => this.settings = settings;

  @override
  Future<void> createTab(String tabId, {required bool incognito, String? url, bool desktopMode = false}) async {
    calls.add('createTab:$tabId:${incognito ? 'private' : 'regular'}:${url ?? ''}');
    created.add(tabId);
    if (url != null) loaded[tabId] = url;
  }

  @override
  Future<void> disposeTab(String tabId) async {
    calls.add('disposeTab:$tabId');
    disposed.add(tabId);
  }

  @override
  Future<void> suspendTab(String tabId) async {
    calls.add('suspendTab:$tabId');
    suspended.add(tabId);
  }

  @override
  Future<void> setTabVisible(String tabId, bool visible) async => calls.add('visible:$tabId:$visible');

  @override
  Future<void> loadUrl(String tabId, String url) async {
    calls.add('loadUrl:$tabId:$url');
    loaded[tabId] = url;
  }

  @override
  Future<void> goBack(String tabId) async => calls.add('goBack:$tabId');

  @override
  Future<void> goForward(String tabId) async => calls.add('goForward:$tabId');

  @override
  Future<void> reload(String tabId) async => calls.add('reload:$tabId');

  @override
  Future<void> stop(String tabId) async => calls.add('stop:$tabId');

  @override
  Future<void> setDesktopMode(String tabId, bool enabled) async => calls.add('desktop:$tabId:$enabled');

  @override
  Future<void> setTextZoom(String tabId, int? percent) async => calls.add('zoom:$tabId:$percent');

  @override
  Future<void> find(String tabId, String query) async => calls.add('find:$tabId:$query');

  @override
  Future<void> findNext(String tabId, {required bool forward}) async => calls.add('findNext:$tabId:$forward');

  @override
  Future<void> clearFind(String tabId) async => calls.add('clearFind:$tabId');

  @override
  Future<Uint8List?> captureThumbnail(String tabId, {int maxWidth = 360}) async => Uint8List.fromList([1, 2, 3]);

  @override
  Future<String> fillCredential(
    String tabId, {
    required String origin,
    required String username,
    required String password,
  }) async {
    calls.add('fill:$tabId:$origin:$username');
    return 'ok';
  }

  @override
  Future<String?> readBlob(String tabId, String url) async => base64.encode(utf8.encode('blob-content'));

  @override
  Future<void> allowHttpHost(String host) async => allowedHttpHosts.add(host);

  @override
  Future<bool> exitFullscreen() async => true;

  @override
  Future<void> respondFileChooser(int requestId, String source) async => calls.add('file:$requestId:$source');

  @override
  Future<void> respondPermission(int requestId, List<String> granted, {bool remember = false}) async =>
      calls.add('permission:$requestId:${granted.join(',')}');

  @override
  Future<void> respondHttpAuth(int requestId, {String? username, String? password}) async =>
      calls.add('auth:$requestId:${username ?? '-'}');

  @override
  Future<bool> requestAndroidPermissions(List<String> permissions) async => true;

  @override
  Future<void> clearBrowsingData({
    bool cookies = false,
    bool cache = false,
    bool storage = false,
    bool httpAuth = false,
    bool permissions = false,
  }) async {
    lastClear = {'cookies': cookies, 'cache': cache, 'storage': storage, 'httpAuth': httpAuth};
  }

  @override
  Future<bool> endIncognitoSession() async {
    endIncognitoCalls++;
    calls.add('endIncognito');
    return true;
  }

  @override
  Future<void> setProxyOverride(String proxyUrl) async {
    if (!proxySupported) throw UnsupportedError('no proxy override');
    this.proxyUrl = proxyUrl;
  }

  @override
  Future<bool> clearProxyOverride() async {
    proxyUrl = null;
    return true;
  }

  @override
  Future<bool> isOnline() async => true;

  @override
  Future<String?> getCookies(String url, {required bool incognito}) async => incognito ? null : 'sid=1';
}

const testUserAgent =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/AP1A; wv) AppleWebKit/537.36 (KHTML, like Gecko) '
    'Version/4.0 Chrome/129.0.6668.100 Mobile Safari/537.36';

/// In-memory system services; downloads are driven by the test.
class FakeSystemBridge implements SystemBridge {
  FakeSystemBridge(this.downloadsDir);

  final String downloadsDir;
  final StreamController<IncomingIntent> intentController = StreamController.broadcast();
  final Map<int, SystemDownloadStatus> systemDownloads = {};
  final List<String> calls = [];
  bool secure = false;
  int _nextId = 100;

  @override
  Stream<IncomingIntent> get intents => intentController.stream;

  @override
  Future<IncomingIntent?> consumeInitialIntent() async => null;

  @override
  Future<Uint8List> encrypt(Uint8List data, String associatedData) => FakeCipher.encryptBytes(data, associatedData);

  @override
  Future<Uint8List> decrypt(Uint8List data, String associatedData) => FakeCipher.decryptBytes(data, associatedData);

  @override
  Future<void> setSecure(bool secure) async => this.secure = secure;

  @override
  Future<void> moveToBack() async => calls.add('moveToBack');

  @override
  Future<bool> openExternal(String url) async {
    calls.add('openExternal:$url');
    return true;
  }

  @override
  Future<bool> shareText(String text, {String? subject}) async => true;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<String> appDownloadsDir() async => downloadsDir;

  @override
  Future<int> enqueueDownload({
    required String url,
    required String fileName,
    String? mimeType,
    String? userAgent,
    String? referer,
    required bool incognito,
  }) async {
    final id = _nextId++;
    calls.add('enqueue:$id:$fileName');
    systemDownloads[id] = SystemDownloadStatus(id: id, status: 'pending');
    return id;
  }

  @override
  Future<List<SystemDownloadStatus>> queryDownloads(List<int> ids) async => [
    for (final id in ids) systemDownloads[id] ?? SystemDownloadStatus(id: id, status: 'missing'),
  ];

  @override
  Future<void> removeDownload(int id) async {
    calls.add('remove:$id');
    systemDownloads.remove(id);
  }

  @override
  Future<bool> openFile({int? systemId, String? path, String? mimeType}) async {
    calls.add('open:${systemId ?? path}');
    return true;
  }

  @override
  Future<bool> shareFile({int? systemId, String? path, String? mimeType}) async => true;

  @override
  Future<bool> saveCopy({int? systemId, String? path, required String fileName, String? mimeType}) async {
    calls.add('saveCopy:$fileName');
    return true;
  }
}

/// Test cipher with the same contract as the Keystore cipher: output never
/// contains the plaintext and decryption fails if the associated data differs.
class FakeCipher implements VaultCipher {
  static Future<Uint8List> encryptBytes(Uint8List data, String aad) async {
    final tag = utf8.encode(aad).fold<int>(17, (a, b) => (a * 31 + b) & 0xFF);
    return Uint8List.fromList([tag, ...data.reversed.map((b) => b ^ 0x5A ^ tag)]);
  }

  static Future<Uint8List> decryptBytes(Uint8List blob, String aad) async {
    final tag = utf8.encode(aad).fold<int>(17, (a, b) => (a * 31 + b) & 0xFF);
    if (blob.isEmpty || blob.first != tag) throw StateError('authentication failed');
    return Uint8List.fromList(blob.skip(1).map((b) => b ^ 0x5A ^ tag).toList().reversed.toList());
  }

  @override
  Future<Uint8List> encrypt(String plain, String associatedData) =>
      encryptBytes(Uint8List.fromList(utf8.encode(plain)), associatedData);

  @override
  Future<String> decrypt(Uint8List blob, String associatedData) async =>
      utf8.decode(await decryptBytes(blob, associatedData));
}

bool _ffiReady = false;

Future<AppDatabase> openTestDatabase([String? path]) {
  if (!_ffiReady) {
    sqfliteFfiInit();
    _ffiReady = true;
  }
  return AppDatabase.open(factory: databaseFactoryFfi, path: path ?? inMemoryDatabasePath);
}

/// Bundles a provider container with its fakes.
class TestHarness {
  TestHarness._(this.container, this.engine, this.system, this.database, this.directory);

  final ProviderContainer container;
  final FakeBrowserEngine engine;
  final FakeSystemBridge system;
  final AppDatabase database;
  final Directory directory;

  static Future<TestHarness> create({
    Directory? directory,
    AppDatabase? database,
    Map<String, Object> prefs = const {},
    List<Override> overrides = const [],
    FakeBrowserEngine? engine,
  }) async {
    final dir = directory ?? await Directory.systemTemp.createTemp('saif_test');
    SharedPreferences.setMockInitialValues(prefs);
    final preferences = await SharedPreferences.getInstance();
    final db = database ?? await openTestDatabase('${dir.path}/browser.db');
    final fakeEngine = engine ?? FakeBrowserEngine();
    final system = FakeSystemBridge('${dir.path}/downloads');
    final info = await fakeEngine.init();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(preferences),
        browserEngineProvider.overrideWithValue(fakeEngine),
        systemBridgeProvider.overrideWithValue(system),
        engineInfoProvider.overrideWithValue(info),
        appSupportDirProvider.overrideWithValue(dir.path),
        vaultCipherProvider.overrideWithValue(FakeCipher()),
        ...overrides,
      ],
    );
    return TestHarness._(container, fakeEngine, system, db, dir);
  }

  void dispose() {
    container.dispose();
    database.close();
  }
}

/// Lets queued microtasks and timers with zero delay run.
Future<void> pump([int times = 5]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
