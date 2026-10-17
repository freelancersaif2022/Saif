import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ui.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum ToastType { success, error, info, reward }

/// Floating, branded snackbars that work from anywhere (services included).
class AppToast {
  AppToast._();

  static void show(String message, {ToastType type = ToastType.info, String? title, String? actionLabel, VoidCallback? onAction}) {
    final messenger = rootMessengerKey.currentState;
    if (messenger == null) return;
    final (color, icon) = switch (type) {
      ToastType.success => (AppColors.success, Icons.check_circle_rounded),
      ToastType.error => (AppColors.danger, Icons.error_rounded),
      ToastType.info => (AppColors.cyan, Icons.info_rounded),
      ToastType.reward => (AppColors.gold, Icons.card_giftcard_rounded),
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          duration: Duration(milliseconds: actionLabel != null ? 4500 : 2600),
          content: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF241C45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.55), width: 1.2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 6)),
                const BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) Text(title, style: AppText.h3.copyWith(color: color)),
                      Text(
                        message,
                        style: AppText.label.copyWith(fontWeight: FontWeight.w700, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      onAction?.call();
                    },
                    child: Text(
                      actionLabel.toUpperCase(),
                      style: AppText.label.copyWith(color: color, fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
  }
}

/// Animated, game-styled popup.
class AppDialog {
  AppDialog._();

  static Future<T?> show<T>({
    BuildContext? context,
    required String title,
    String? message,
    Widget? hero,
    Widget? body,
    String? primaryLabel,
    IconData? primaryIcon,
    Color primaryColor = AppColors.primary,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
    bool dismissible = true,
    Color accent = AppColors.primary,
  }) {
    final ctx = context ?? rootNavigatorKey.currentContext!;
    return showGeneralDialog<T>(
      context: ctx,
      barrierDismissible: dismissible,
      barrierLabel: 'dialog',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (c, _, _) => PopScope(
        canPop: dismissible,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E2458), Color(0xFF1A1433)]),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.4),
                    boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 40, spreadRadius: 2)],
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?hero,
                      if (hero != null) const SizedBox(height: 12),
                      Text(title, textAlign: TextAlign.center, style: AppText.h1),
                      if (message != null) ...[const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: AppText.body)],
                      if (body != null) ...[const SizedBox(height: 14), body],
                      const SizedBox(height: 20),
                      if (primaryLabel != null) GameButton(label: primaryLabel, icon: primaryIcon, color: primaryColor, expand: true, onTap: onPrimary ?? () => Navigator.of(c).pop(true)),
                      if (secondaryLabel != null) ...[
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: onSecondary ?? () => Navigator.of(c).pop(false),
                          child: Text(secondaryLabel, style: AppText.label.copyWith(color: AppColors.textDim)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (c, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  static Future<bool> confirm({
    BuildContext? context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData icon = Icons.help_rounded,
  }) async {
    final color = destructive ? AppColors.danger : AppColors.primary;
    final r = await show<bool>(
      context: context,
      title: title,
      message: message,
      accent: color,
      hero: IconBadge(icon: icon, color: color),
      primaryLabel: confirmLabel,
      primaryColor: color,
      secondaryLabel: cancelLabel,
    );
    return r == true;
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 68});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0.08)]),
      border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
    ),
    child: Icon(icon, color: color, size: size * 0.5),
  );
}
