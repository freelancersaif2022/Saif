import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/engine/system_bridge.dart';
import 'package:saif_browser/features/downloads/download_item.dart';
import 'package:saif_browser/features/downloads/downloads_controller.dart';
import 'package:saif_browser/features/settings/browser_settings.dart';
import 'package:saif_browser/features/settings/settings_controller.dart';

import '../support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestHarness h;
  late DownloadsController downloads;

  setUp(() async {
    h = await TestHarness.create();
    downloads = h.container.read(downloadsProvider.notifier);
    await downloads.ensureLoaded();
  });
  tearDown(() async {
    h.dispose();
    await h.directory.delete(recursive: true);
  });

  List<DownloadItem> items() => h.container.read(downloadsProvider);

  DownloadRequest request(String url, {String name = 'report.pdf', bool incognito = false}) => DownloadRequest(
    url: url,
    fileName: name,
    mimeType: 'application/pdf',
    contentLength: 1000,
    incognito: incognito,
    tabId: 't1',
  );

  test('HTTP downloads go to Android DownloadManager and progress is polled', () async {
    final item = await downloads.start(request('https://files.example/report.pdf'));
    expect(item.engine, DownloadEngine.system);
    expect(h.system.calls, contains('enqueue:${item.systemId}:report.pdf'));

    h.system.systemDownloads[item.systemId!] = SystemDownloadStatus(
      id: item.systemId!,
      status: 'running',
      received: 400,
      total: 1000,
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    expect(items().single.status, DownloadStatus.running);
    expect(items().single.fraction, closeTo(0.4, 0.01));

    h.system.systemDownloads[item.systemId!] = SystemDownloadStatus(
      id: item.systemId!,
      status: 'completed',
      received: 1000,
      total: 1000,
    );
    final completed = downloads.completions.first;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    expect((await completed).id, item.id);
    expect(items().single.status, DownloadStatus.completed);

    await downloads.open(item.id);
    expect(h.system.calls, contains('open:${item.systemId}'));
  });

  test('cancel, retry and delete', () async {
    final item = await downloads.start(request('https://files.example/a.zip', name: 'a.zip'));
    await downloads.cancel(item.id);
    expect(items().single.status, DownloadStatus.canceled);
    expect(h.system.calls, contains('remove:${item.systemId}'));

    await downloads.retry(item.id);
    final retried = items().single;
    expect(retried.status, DownloadStatus.queued);
    expect(retried.systemId, isNot(item.systemId));

    await downloads.remove(item.id, deleteFile: true);
    expect(items(), isEmpty);
  });

  test('failed system downloads report the reason', () async {
    final item = await downloads.start(request('https://files.example/big.iso', name: 'big.iso'));
    h.system.systemDownloads[item.systemId!] = SystemDownloadStatus(id: item.systemId!, status: 'failed', reason: 1006);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    expect(items().single.status, DownloadStatus.failed);
    expect(items().single.error, 'Not enough storage space');
  });

  test('duplicate file names get a numbered suffix', () async {
    await downloads.start(request('https://files.example/report.pdf'));
    final second = await downloads.start(request('https://files.example/report.pdf'));
    expect(second.fileName, 'report (1).pdf');
  });

  test('data: URLs are saved directly', () async {
    final item = await downloads.start(request('data:text/plain;base64,aGVsbG8gd29ybGQ=', name: 'hello.txt'));
    expect(item.status, DownloadStatus.completed);
    expect(item.engine, DownloadEngine.inline);
    expect(await File(item.filePath!).readAsString(), 'hello world');
  });

  test('blob: URLs are read from the page', () async {
    final item = await downloads.start(request('blob:https://app.example/1234', name: 'export.txt'));
    expect(await File(item.filePath!).readAsString(), 'blob-content');
  });

  test('unsupported schemes are rejected', () async {
    await expectLater(downloads.start(request('ftp://old.example/file')), throwsA(isA<DownloadStartException>()));
  });

  test('"ask where to save" opens the system save dialog when done', () async {
    await h.container.read(settingsProvider.notifier).update((s) => s.copyWith(downloadLocation: DownloadLocation.ask));
    await downloads.start(request('data:text/plain;base64,aGk=', name: 'hi.txt'));
    await pump();
    expect(h.system.calls, contains('saveCopy:hi.txt'));
  });

  test('download history persists across restarts', () async {
    await downloads.start(request('data:text/plain;base64,aGk=', name: 'keep.txt'));
    final db = h.database;
    final restarted = await TestHarness.create(directory: h.directory, database: db);
    final controller = restarted.container.read(downloadsProvider.notifier);
    await controller.ensureLoaded();
    expect(restarted.container.read(downloadsProvider).single.fileName, 'keep.txt');
    restarted.container.dispose();
  });
}
