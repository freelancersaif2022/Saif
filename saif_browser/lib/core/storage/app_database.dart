import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local SQLite database for bookmarks, history, downloads, credentials,
/// site permissions, shortcuts, favicons and proxies. Nothing in it is synced.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const int schemaVersion = 2;
  static const String fileName = 'saif_browser.db';

  /// Opens (or creates and migrates) the database. If the file is corrupted it
  /// is moved aside and a fresh database is created so the app still starts.
  static Future<AppDatabase> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), fileName);
    try {
      return AppDatabase._(await _openAt(dbFactory, dbPath));
    } on Exception catch (e) {
      if (e is! DatabaseException && e is! CorruptDatabaseException) rethrow;
      if (dbPath == inMemoryDatabasePath) rethrow;
      await dbFactory.deleteDatabase(dbPath);
      return AppDatabase._(await _openAt(dbFactory, dbPath));
    }
  }

  static Future<Database> _openAt(DatabaseFactory factory, String path) async {
    final database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          final batch = db.batch();
          _createSchema(batch);
          await batch.commit(noResult: true);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await db.execute(_httpAuthTable);
        },
      ),
    );
    final check = await database.rawQuery('PRAGMA quick_check');
    if (check.isEmpty || check.first.values.first != 'ok') {
      await database.close();
      throw const CorruptDatabaseException();
    }
    return database;
  }

  static void _createSchema(Batch b) {
    b.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER REFERENCES bookmarks(id) ON DELETE CASCADE,
        is_folder INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL,
        url TEXT,
        position INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )''');
    b.execute('CREATE INDEX idx_bookmarks_parent ON bookmarks(parent_id, position)');
    b.execute('CREATE INDEX idx_bookmarks_url ON bookmarks(url)');

    b.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        host TEXT NOT NULL DEFAULT '',
        visited_at INTEGER NOT NULL
      )''');
    b.execute('CREATE INDEX idx_history_time ON history(visited_at DESC)');
    b.execute('CREATE INDEX idx_history_url ON history(url)');
    b.execute('CREATE INDEX idx_history_host ON history(host)');

    b.execute('''
      CREATE TABLE favicons (
        host TEXT PRIMARY KEY,
        data BLOB NOT NULL,
        updated_at INTEGER NOT NULL
      )''');

    b.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        file_name TEXT NOT NULL,
        mime_type TEXT,
        total_bytes INTEGER NOT NULL DEFAULT -1,
        received_bytes INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        engine TEXT NOT NULL,
        system_id INTEGER,
        file_path TEXT,
        error TEXT,
        user_agent TEXT,
        referer TEXT,
        incognito INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER
      )''');

    b.execute('''
      CREATE TABLE credentials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        origin TEXT NOT NULL,
        username TEXT NOT NULL,
        password_blob BLOB NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(origin, username)
      )''');

    b.execute('''
      CREATE TABLE site_permissions (
        origin TEXT NOT NULL,
        permission TEXT NOT NULL,
        decision TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY(origin, permission)
      )''');

    b.execute('''
      CREATE TABLE shortcuts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0
      )''');

    b.execute(_httpAuthTable);

    b.execute('''
      CREATE TABLE proxies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        host TEXT NOT NULL,
        port INTEGER NOT NULL,
        username TEXT,
        password_blob BLOB,
        created_at INTEGER NOT NULL
      )''');
  }

  /// Saved credentials for HTTP authentication prompts (sites and network proxies).
  static const _httpAuthTable = '''
      CREATE TABLE http_auth (
        host TEXT NOT NULL,
        realm TEXT NOT NULL,
        is_proxy INTEGER NOT NULL DEFAULT 0,
        username TEXT NOT NULL,
        password_blob BLOB NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY(host, realm)
      )''';

  Future<void> close() => db.close();
}

/// Raised when SQLite's integrity check fails on open.
class CorruptDatabaseException implements Exception {
  const CorruptDatabaseException();

  @override
  String toString() => 'CorruptDatabaseException';
}
