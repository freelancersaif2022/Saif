import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/core/storage/app_database.dart';
import 'package:saif_browser/core/utils/search_engines.dart';
import 'package:saif_browser/features/browser/search_suggestions.dart';
import 'package:saif_browser/features/passwords/http_auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../support/fakes.dart';

void main() {
  test('saved proxy / site sign-ins are encrypted and bound to host + realm', () async {
    final db = await openTestDatabase();
    final repo = HttpAuthRepository(db, FakeCipher());
    await repo.save(
      const HttpAuthLogin(host: 'proxy.lan', realm: 'Squid', isProxy: true, username: 'alice', password: 's3cret!'),
    );
    final row = (await db.db.query('http_auth')).single;
    expect(String.fromCharCodes(row['password_blob']! as Uint8List), isNot(contains('s3cret')));
    final found = await repo.find('proxy.lan', 'Squid');
    expect(found!.password, 's3cret!');
    expect(found.isProxy, isTrue);
    expect(await repo.find('proxy.lan', 'Other'), isNull);
    expect((await repo.all()).single.username, 'alice');
    await repo.delete('proxy.lan', 'Squid');
    expect(await repo.all(), isEmpty);
    await db.close();
  });

  test('version 1 databases are migrated to version 2', () async {
    sqfliteFfiInit();
    final dir = await Directory.systemTemp.createTemp('saif_mig');
    final path = '${dir.path}/old.db';
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute('CREATE TABLE history (id INTEGER PRIMARY KEY, url TEXT)'),
      ),
    );
    await old.close();
    final db = await AppDatabase.open(factory: databaseFactoryFfi, path: path);
    final tables = await db.db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='http_auth'");
    expect(tables, hasLength(1));
    await db.close();
    await dir.delete(recursive: true);
  });

  test('search suggestion responses are parsed (OpenSearch format)', () {
    expect(SearchSuggestionService.parse('["flut",["flutter","flutter dev","",3]]'), ['flutter', 'flutter dev']);
    expect(SearchSuggestionService.parse('{"bad":1}'), isEmpty);
    expect(SearchSuggestionService.endpointFor(SearchEngine.google, 'a b').toString(), contains('q=a+b'));
    expect(SearchSuggestionService.endpointFor(SearchEngine.startpage, 'x'), isNull);
  });
}
