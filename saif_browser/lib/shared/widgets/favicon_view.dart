import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Site icon, or a lettered tile when the site has none.
class FaviconView extends StatelessWidget {
  const FaviconView({super.key, this.bytes, required this.label, this.size = 20});

  final Uint8List? bytes;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final data = bytes;
    if (data != null && data.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.memory(
          data,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => _letter(context),
        ),
      );
    }
    return _letter(context);
  }

  Widget _letter(BuildContext context) {
    final palette = context.palette;
    final text = label.replaceFirst(RegExp(r'^(https?://)?(www\.)?'), '');
    final letter = text.isEmpty ? '•' : text.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: palette.surfaceStrong, borderRadius: BorderRadius.circular(size * 0.22)),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.52,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
