import 'dart:io';

/// Writes files atomically (temp file + rename) so an interrupted write never
/// leaves a truncated file behind.
abstract final class AtomicFile {
  static Future<void> writeString(File file, String contents) async {
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(contents, flush: true);
    await tmp.rename(file.path);
  }

  static Future<String?> readString(File file) async {
    try {
      if (!await file.exists()) return null;
      return await file.readAsString();
    } on FileSystemException {
      return null;
    }
  }
}
