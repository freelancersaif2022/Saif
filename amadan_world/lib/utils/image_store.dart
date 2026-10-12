import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Decodes bundled images once and keeps them for the lifetime of the app.
class ImageStore {
  ImageStore._();

  static final Map<String, ui.Image> _images = {};
  static final Map<String, Future<ui.Image>> _pending = {};

  static Future<ui.Image> load(String path) {
    final cached = _images[path];
    if (cached != null) {
      return Future<ui.Image>.value(cached);
    }
    return _pending.putIfAbsent(path, () => _decode(path));
  }

  static Future<ui.Image> _decode(String path) async {
    try {
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      _images[path] = frame.image;
      return frame.image;
    } finally {
      _pending.remove(path);
    }
  }

  static Future<void> loadAll(Iterable<String> paths) async {
    await Future.wait(paths.map(load));
  }

  static ui.Image get(String path) {
    final image = _images[path];
    if (image == null) {
      throw StateError('Image not loaded: $path');
    }
    return image;
  }

  static ui.Image? tryGet(String path) => _images[path];
}
