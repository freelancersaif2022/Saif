import 'dart:typed_data';

// Web preview build: roars are kept in memory only.
final Map<String, Uint8List> memoryRoars = {};

Future<String?> saveRoar(String id, Uint8List wav) async {
  memoryRoars['mem:$id'] = wav;
  return 'mem:$id';
}

Future<void> deleteRoar(String? path) async => memoryRoars.remove(path);

Future<String?> writeTemp(String name, Uint8List bytes) async => null;

Uint8List? memoryRoarBytes(String path) => memoryRoars[path];
