import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

/// App-wide messenger so connection notices can appear on any screen.
final messengerKey = GlobalKey<ScaffoldMessengerState>();

enum ToastKind { info, success, error, offline }

extension on ToastKind {
  IconData get icon => switch (this) {
        ToastKind.info => Icons.info_outline_rounded,
        ToastKind.success => Icons.check_circle_outline_rounded,
        ToastKind.error => Icons.error_outline_rounded,
        ToastKind.offline => Icons.wifi_off_rounded,
      };

  Color get color => switch (this) {
        ToastKind.info => GC.amber,
        ToastKind.success => GC.green,
        ToastKind.error => GC.coral,
        ToastKind.offline => GC.coral,
      };
}

/// A floating, rounded message with an icon badge, an optional subtitle and action.
void showToast(
  String title, {
  BuildContext? context,
  String? message,
  ToastKind kind = ToastKind.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = context != null ? ScaffoldMessenger.maybeOf(context) : messengerKey.currentState;
  if (messenger == null) return;
  if (kind == ToastKind.error || kind == ToastKind.offline) HapticFeedback.mediumImpact();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      dismissDirection: DismissDirection.horizontal,
      content: _ToastBody(
        kind: kind,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                messenger.hideCurrentSnackBar();
                onAction();
              },
      ),
    ));
}

void hideToast({BuildContext? context}) {
  final messenger = context != null ? ScaffoldMessenger.maybeOf(context) : messengerKey.currentState;
  messenger?.hideCurrentSnackBar();
}

class _ToastBody extends StatelessWidget {
  const _ToastBody({required this.kind, required this.title, this.message, this.actionLabel, this.onAction});
  final ToastKind kind;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF23201A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kind.color.withValues(alpha: 0.35)),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: kind.color.withValues(alpha: 0.16), shape: BoxShape.circle),
            child: Icon(kind.icon, color: kind.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GC.body(14.5, color: GC.text, weight: FontWeight.w700, height: 1.25)),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(message!, style: GC.body(13, color: GC.muted, height: 1.35)),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: kind.color,
                textStyle: GC.body(14, weight: FontWeight.w800, height: 1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              child: Text(actionLabel!),
            )
          else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/// A consistent popup: icon badge, serif title, body and up to two buttons.
Future<bool?> showGhostDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.info_outline_rounded,
  String confirmLabel = 'OK',
  String? cancelLabel,
  bool destructive = false,
}) {
  final accent = destructive ? GC.coral : GC.amber;
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
      );
    },
    pageBuilder: (ctx, _, _) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Material(
          color: GC.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: GC.line)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle),
                  child: Icon(icon, color: accent, size: 28),
                ),
                const SizedBox(height: 16),
                Text(title, textAlign: TextAlign.center, style: GC.display(23, height: 1.2)),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center, style: GC.body(15, color: GC.muted, height: 1.5)),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: GC.onAmber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM)),
                      textStyle: GC.body(15.5, weight: FontWeight.w700, height: 1),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
                if (cancelLabel != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: GC.textSoft,
                        textStyle: GC.body(15, weight: FontWeight.w600, height: 1),
                      ),
                      child: Text(cancelLabel),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Full-area state for "you're offline", "nothing here" and errors.
class StatePanel extends StatelessWidget {
  const StatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.color = GC.amber,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Color color;

  const StatePanel.offline({super.key, this.onAction})
      : icon = Icons.wifi_off_rounded,
        title = 'You’re offline',
        message = 'Connect to Wi-Fi or mobile data to load photos and maps. Your saved places and memories still work.',
        actionLabel = 'Try again',
        secondaryLabel = null,
        onSecondary = null,
        color = GC.coral;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 34),
          ),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: GC.display(23, height: 1.2)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: GC.body(14.5, color: GC.muted, height: 1.5)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: GC.amber,
                  foregroundColor: GC.onAmber,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM)),
                  textStyle: GC.body(15, weight: FontWeight.w700, height: 1),
                ),
              ),
            ),
          ],
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(foregroundColor: GC.amber, textStyle: GC.body(14.5, weight: FontWeight.w700)),
              child: Text(secondaryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
