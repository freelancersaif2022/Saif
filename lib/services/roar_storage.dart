import 'dart:typed_data';

import 'roar_storage_stub.dart' if (dart.library.io) 'roar_storage_io.dart' as impl;

/// Saves each monster's roar as a WAV file in the app's private folder.
class RoarStorage {
  RoarStorage._();
  static Future<String?> save(String id, Uint8List wav) => impl.saveRoar(id, wav);
  static Future<void> delete(String? path) => impl.deleteRoar(path);
  static Future<String?> writeTemp(String name, Uint8List bytes) => impl.writeTemp(name, bytes);
}
