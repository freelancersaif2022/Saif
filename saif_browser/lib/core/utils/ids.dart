import 'dart:math';

final Random _random = Random.secure();

/// Random identifier for tabs and other in-memory objects.
String newId([String prefix = 't']) {
  final bytes = List<int>.generate(12, (_) => _random.nextInt(256));
  return '$prefix-${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
}
