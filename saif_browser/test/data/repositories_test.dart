import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/features/bookmarks/bookmark_repository.dart';
import 'package:saif_browser/features/downloads/download_item.dart';
import 'package:saif_browser/features/downloads/download_repository.dart';
import 'package:saif_browser/features/history/favicon_repository.dart';
import 'package:saif_browser/features/history/history_repository.dart';
import 'package:saif_browser/features/passwords/credential_repository.dart';
import 'package:saif_browser/features/permissions/site_permission_repository.dart';
import 'package:saif_browser/features/proxy/proxy_models.dart';
import 'package:saif_browser/features/proxy/proxy_repository.dart';
import 'package:saif_browser/features/shortcuts/shortcut_repository.dart';

import '../support/fakes.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('saif_db'));
  tearDown(() async => dir.delete(recursive: true));

  group('Bookmarks', () {
    test('persist across database reopen (app restart)', () async {
      final path = '${dir.path}/b.db';
      var db = await openTestDatabase(path);
      final repo = BookmarkRepository(db);
      final folder = await repo.addFolder('Work');
      await repo.add(title: 'Flutter', url: 'https://flutter.dev/');
      await repo.add(title: 'Docs', url: 'https://docs.flutter.dev/', parentId: folder);
      await db.close();

      db = await openTestDatabase(path);
      final reopened = BookmarkRepository(db);
      final root = await reopened.children(null);
      expect(root.map((b) => b.title), ['Work', 'Flutter']);
      expect(root.first.isFolder, isTrue);
      expect((await reopened.children(folder)).single.url, 'https://docs.flutter.dev/');
      await db.close();
    });

    test('edit, move, search, reorder and delete', () async {
      final db = await openTestDatabase();
      final repo = BookmarkRepository(db);
      final folder = await repo.addFolder('Reading');
      final a = await repo.add(title: 'A', url: 'https://a.example/');
      final b = await repo.add(title: 'B 100%', url: 'https://b.example/');
      await repo.update(a, title: 'Alpha', url: 'https://alpha.example/', parentId: folder);
      expect((await repo.children(folder)).single.title, 'Alpha');
      expect((await repo.search('alpha')).single.id, a);
      expect((await repo.search('100%')).single.id, b, reason: 'LIKE wildcards are escaped');
      expect(await repo.findByUrl('https://b.example/'), isNotNull);

      final c = await repo.add(title: 'C', url: 'https://c.example/');
      await repo.reorder([c, b]);
      expect((await repo.children(null)).where((x) => !x.isFolder).map((x) => x.id), [c, b]);

      expect(() => repo.update(folder, title: 'Reading', parentId: folder), throwsArgumentError);

      await repo.delete(folder);
      expect(await repo.byId(a), isNull, reason: 'deleting a folder deletes its contents');
      await db.close();
    });
  });

  group('History', () {
    test('records visits, merges reloads and survives reopen', () async {
      final path = '${dir.path}/h.db';
      var now = DateTime(2026, 10, 13, 10);
      var db = await openTestDatabase(path);
      var repo = HistoryRepository(db, clock: () => now);
      await repo.recordVisit('https://a.example/', 'A');
      await repo.recordVisit('https://a.example/', 'A again');
      now = now.add(const Duration(minutes: 5));
      await repo.recordVisit('https://b.example/', 'B');
      await repo.recordVisit('about:blank', 'ignored');
      expect(await repo.count(), 2);
      await db.close();

      db = await openTestDatabase(path);
      repo = HistoryRepository(db, clock: () => now);
      final page = await repo.page();
      expect(page.map((e) => e.title), ['B', 'A again']);
      expect((await repo.page(query: 'a.example')).single.url, 'https://a.example/');
      await db.close();
    });

    test('delete one entry, clear by range and clear all', () async {
      var now = DateTime(2026, 10, 13, 10);
      final db = await openTestDatabase();
      final repo = HistoryRepository(db, clock: () => now);
      await repo.recordVisit('https://old.example/', 'Old');
      now = now.add(const Duration(days: 3));
      await repo.recordVisit('https://new.example/', 'New');
      final entries = await repo.page();
      await repo.delete(entries.first.id);
      expect((await repo.page()).single.title, 'Old');

      await repo.recordVisit('https://new.example/', 'New');
      final removed = await repo.clear(since: now.subtract(const Duration(days: 1)));
      expect(removed, 1);
      expect((await repo.page()).single.title, 'Old');
      await repo.clear();
      expect(await repo.count(), 0);
      await db.close();
    });

    test('top sites and suggestions', () async {
      final now = DateTime(2026, 10, 13, 10);
      var t = now;
      final db = await openTestDatabase();
      final repo = HistoryRepository(db, clock: () => t);
      for (var i = 0; i < 3; i++) {
        t = t.add(const Duration(hours: 1));
        await repo.recordVisit('https://popular.example/p$i', 'Popular');
      }
      t = t.add(const Duration(hours: 1));
      await repo.recordVisit('https://rare.example/', 'Rare');
      final top = await repo.topSites();
      expect(top.first.host, 'popular.example');
      expect(top.first.url, 'https://popular.example/');
      expect((await repo.suggestions('rare')).single.url, 'https://rare.example/');
      await db.close();
    });

    test('favicons cache and prune', () async {
      final db = await openTestDatabase();
      final favicons = FaviconRepository(db);
      await favicons.save('gone.example', Uint8List.fromList([1, 2]));
      expect(await favicons.load('gone.example'), [1, 2]);
      await favicons.prune();
      expect(await favicons.load('gone.example'), isNull);
      await db.close();
    });
  });

  group('Password encryption', () {
    test('passwords are stored only as ciphertext bound to origin and username', () async {
      final db = await openTestDatabase();
      final repo = CredentialRepository(db, FakeCipher());
      final id = await repo.save(origin: 'https://login.example', username: 'alice', password: 'hunter2-secret');

      final rows = await db.db.query('credentials');
      final blob = rows.single['password_blob']! as Uint8List;
      expect(String.fromCharCodes(blob), isNot(contains('hunter2')));
      expect(rows.single.values.whereType<String>().any((v) => v.contains('hunter2')), isFalse);
      expect(await repo.revealPassword(id), 'hunter2-secret');

      // Moving the ciphertext to another account must fail authentication.
      final other = await repo.save(origin: 'https://login.example', username: 'mallory', password: 'x');
      await db.db.update('credentials', {'password_blob': blob}, where: 'id = ?', whereArgs: [other]);
      expect(() => repo.revealPassword(other), throwsStateError);
      await db.close();
    });

    test('save updates existing login, edit re-encrypts, search, delete', () async {
      final db = await openTestDatabase();
      final repo = CredentialRepository(db, FakeCipher());
      final id = await repo.save(origin: 'https://a.example', username: 'bob', password: 'one');
      expect(await repo.save(origin: 'https://a.example', username: 'bob', password: 'two'), id);
      expect(await repo.revealPassword(id), 'two');
      await repo.update(id, origin: 'https://b.example', username: 'robert', password: 'three');
      expect(await repo.revealPassword(id), 'three');
      expect((await repo.all(query: 'robert')).single.origin, 'https://b.example');
      expect(await repo.forOrigin('https://a.example'), isEmpty);
      await repo.delete(id);
      expect(await repo.count(), 0);
      await db.close();
    });
  });

  test('site permissions', () async {
    final db = await openTestDatabase();
    final repo = SitePermissionRepository(db);
    await repo.set('https://meet.example', SitePermission.camera, PermissionDecision.allow);
    await repo.set('https://meet.example', SitePermission.microphone, PermissionDecision.block);
    expect(await repo.decision('https://meet.example', SitePermission.camera), PermissionDecision.allow);
    expect(await repo.decision('https://meet.example', SitePermission.location), isNull);
    expect((await repo.all()).length, 2);
    await repo.remove('https://meet.example', SitePermission.camera);
    expect(await repo.decision('https://meet.example', SitePermission.camera), isNull);
    await db.close();
  });

  test('shortcuts', () async {
    final db = await openTestDatabase();
    final repo = ShortcutRepository(db);
    final id = await repo.add('News', 'https://news.example/');
    await repo.add('Mail', 'https://mail.example/');
    await repo.update(id, 'Headlines', 'https://news.example/top');
    expect((await repo.all()).map((s) => s.title), ['Headlines', 'Mail']);
    await repo.delete(id);
    expect((await repo.all()).single.title, 'Mail');
    await db.close();
  });

  test('proxy passwords are encrypted and kept on edit', () async {
    final db = await openTestDatabase();
    final repo = ProxyRepository(db, FakeCipher());
    final id = await repo.add(
      name: '',
      type: ProxyType.socks5,
      host: 'proxy.example',
      port: 1080,
      username: 'u',
      password: 'p@ss',
    );
    final row = (await db.db.query('proxies')).single;
    expect(row['name'], 'proxy.example:1080');
    expect(String.fromCharCodes(row['password_blob']! as Uint8List), isNot(contains('p@ss')));
    expect((await repo.upstreamFor(id))!.password, 'p@ss');

    await repo.update(id, name: 'Home', type: ProxyType.socks5, host: 'proxy2.example', port: 1081, username: 'u');
    expect((await repo.upstreamFor(id))!.password, 'p@ss', reason: 'null password keeps the saved one');
    await repo.update(
      id,
      name: 'Home',
      type: ProxyType.http,
      host: 'proxy2.example',
      port: 8080,
      username: 'u',
      password: '',
    );
    expect((await repo.byId(id))!.hasPassword, isFalse);
    await db.close();
  });

  test('app-engine downloads are marked interrupted after restart', () async {
    final db = await openTestDatabase();
    final repo = DownloadRepository(db);
    DownloadItem item(DownloadEngine engine) => DownloadItem(
      id: 0,
      url: 'https://x.example/f.bin',
      fileName: 'f.bin',
      status: DownloadStatus.running,
      engine: engine,
      createdAt: DateTime(2026),
    );
    await repo.insert(item(DownloadEngine.app));
    await repo.insert(item(DownloadEngine.system));
    await repo.markInterrupted();
    final all = await repo.all();
    expect(all.firstWhere((d) => d.engine == DownloadEngine.app).status, DownloadStatus.failed);
    expect(all.firstWhere((d) => d.engine == DownloadEngine.system).status, DownloadStatus.running);
    await db.close();
  });

  test('a corrupted database file is replaced instead of crashing', () async {
    final path = '${dir.path}/corrupt.db';
    await File(path).writeAsBytes(List<int>.generate(4096, (i) => i % 251));
    final db = await openTestDatabase(path);
    expect(await HistoryRepository(db).count(), 0);
    await db.close();
  });
}
