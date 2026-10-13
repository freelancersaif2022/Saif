import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Confirmation as a bottom sheet with an icon, title, message and two
/// full-width buttons.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    builder: (context) {
      final palette = context.palette;
      final error = Theme.of(context).colorScheme.error;
      final glyph = icon ?? (destructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded);
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: destructive ? error.withValues(alpha: 0.1) : palette.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(glyph, color: destructive ? error : palette.onAccent, size: 26),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: palette.textSecondary, height: 1.45, fontSize: 15)),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: destructive
                        ? FilledButton.styleFrom(backgroundColor: error, foregroundColor: Colors.white)
                        : null,
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

/// Floating message with an accent icon badge and optional action.
void showMessage(BuildContext context, String message, {SnackBarAction? action, IconData? icon}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final palette = context.palette;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: Duration(milliseconds: action == null ? 2600 : 4500),
      content: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon ?? _iconFor(message), size: 18, color: palette.onAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      action: action,
    ),
  );
}

IconData _iconFor(String message) {
  final m = message.toLowerCase();
  if (m.contains('blocked')) return Icons.block_rounded;
  if (m.startsWith('downloading')) return Icons.downloading_rounded;
  if (m.startsWith('downloaded')) return Icons.download_done_rounded;
  if (m.contains('copied')) return Icons.content_copy_rounded;
  const problems = [
    "can't",
    'can’t',
    'could not',
    'no app',
    'not ',
    'failed',
    'invalid',
    'needs',
    'no password',
    'unable',
  ];
  if (problems.any(m.contains)) return Icons.info_outline_rounded;
  return Icons.check_rounded;
}
