import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String?> saveRoar(String id, Uint8List wav) async {
  final dir = await getApplicationDocumentsDirectory();
  final roars = Directory('${dir.path}/roars');
  if (!await roars.exists()) await roars.create(recursive: true);
  final f = File('${roars.path}/$id.wav');
  await f.writeAsBytes(wav, flush: true);
  return f.path;
}

Future<void> deleteRoar(String? path) async {
  if (path == null) return;
  final f = File(path);
  if (await f.exists()) await f.delete();
}

Future<String?> writeTemp(String name, Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  final f = File('${dir.path}/$name');
  await f.writeAsBytes(bytes, flush: true);
  return f.path;
}

Uint8List? memoryRoarBytes(String path) => null;
