import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/app_database.dart';
import '../engine/browser_engine.dart';
import '../engine/engine_event.dart';
import '../engine/system_bridge.dart';
import '../features/bookmarks/bookmark_repository.dart';
import '../features/history/favicon_repository.dart';
import '../features/history/history_repository.dart';
import '../features/passwords/credential_repository.dart';
import '../features/passwords/vault_cipher.dart';
import '../features/permissions/site_permission_repository.dart';
import '../features/proxy/proxy_repository.dart';
import '../features/settings/settings_repository.dart';
import '../features/shortcuts/shortcut_repository.dart';
import '../features/downloads/download_repository.dart';

/// Overridden in `bootstrap` with live instances and in tests with fakes.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider'));
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider'),
);
final browserEngineProvider = Provider<BrowserEngine>((ref) => throw UnimplementedError('browserEngineProvider'));
final systemBridgeProvider = Provider<SystemBridge>((ref) => throw UnimplementedError('systemBridgeProvider'));
final engineInfoProvider = Provider<EngineInfo>((ref) => throw UnimplementedError('engineInfoProvider'));

/// Directory for the tab session file.
final appSupportDirProvider = Provider<String>((ref) => throw UnimplementedError('appSupportDirProvider'));

final vaultCipherProvider = Provider<VaultCipher>((ref) => KeystoreVaultCipher(ref.watch(systemBridgeProvider)));

final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)));
final bookmarkRepositoryProvider = Provider((ref) => BookmarkRepository(ref.watch(databaseProvider)));
final historyRepositoryProvider = Provider((ref) => HistoryRepository(ref.watch(databaseProvider)));
final faviconRepositoryProvider = Provider((ref) => FaviconRepository(ref.watch(databaseProvider)));
final shortcutRepositoryProvider = Provider((ref) => ShortcutRepository(ref.watch(databaseProvider)));
final sitePermissionRepositoryProvider = Provider((ref) => SitePermissionRepository(ref.watch(databaseProvider)));
final credentialRepositoryProvider = Provider(
  (ref) => CredentialRepository(ref.watch(databaseProvider), ref.watch(vaultCipherProvider)),
);
final proxyRepositoryProvider = Provider(
  (ref) => ProxyRepository(ref.watch(databaseProvider), ref.watch(vaultCipherProvider)),
);
final downloadRepositoryProvider = Provider((ref) => DownloadRepository(ref.watch(databaseProvider)));

/// Bumped whenever bookmarks, history or shortcuts change so lists refresh.
final dataRevisionProvider = NotifierProvider<DataRevision, int>(DataRevision.new);

class DataRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
