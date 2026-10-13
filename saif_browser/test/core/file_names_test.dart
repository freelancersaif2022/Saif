import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/core/utils/file_names.dart';
import 'package:saif_browser/core/utils/formatters.dart';

void main() {
  group('FileNames.guess', () {
    test('uses Content-Disposition filename', () {
      expect(
        FileNames.guess('https://x.com/dl?id=1', 'attachment; filename="report 2024.pdf"', 'application/pdf'),
        'report 2024.pdf',
      );
    });

    test('prefers RFC 5987 filename*', () {
      expect(
        FileNames.guess(
          'https://x.com/dl',
          "attachment; filename=\"a.txt\"; filename*=UTF-8''%E2%82%AC%20rates.txt",
          null,
        ),
        '€ rates.txt',
      );
    });

    test('falls back to the URL path and adds an extension from the MIME type', () {
      expect(FileNames.guess('https://x.com/files/archive', null, 'application/zip'), 'archive.zip');
      expect(FileNames.guess('https://x.com/img/photo.jpg?w=200', null, 'image/jpeg'), 'photo.jpg');
      expect(FileNames.guess('https://x.com/', null, null), 'download');
    });

    test('strips path traversal and illegal characters', () {
      expect(FileNames.guess('https://x.com', 'attachment; filename="../../etc/passwd"', null), isNot(contains('/')));
      expect(FileNames.sanitize('a:b*c?.txt'), 'a_b_c_.txt');
      expect(FileNames.sanitize('...hidden'), 'hidden');
    });
  });

  test('unique names for duplicates', () {
    expect(FileNames.unique('a.pdf', {'a.pdf'}), 'a (1).pdf');
    expect(FileNames.unique('a.pdf', {'a.pdf', 'a (1).pdf'}), 'a (2).pdf');
    expect(FileNames.unique('README', {'README'}), 'README (1)');
    expect(FileNames.unique('b.zip', {'a.zip'}), 'b.zip');
  });

  test('formatters', () {
    expect(Formatters.bytes(512), '512 B');
    expect(Formatters.bytes(1536), '1.5 KB');
    expect(Formatters.bytes(5 * 1024 * 1024), '5.0 MB');
    expect(Formatters.bytes(-1), 'Unknown size');
    expect(Formatters.speed(2048), '2.0 KB/s');
    final now = DateTime(2026, 10, 13, 12);
    expect(Formatters.dayHeading(DateTime(2026, 10, 13, 1), now), 'Today');
    expect(Formatters.dayHeading(DateTime(2026, 10, 12, 23), now), 'Yesterday');
    expect(Formatters.dayHeading(DateTime(2025, 1, 2), now), 'Jan 2, 2025');
  });
}
