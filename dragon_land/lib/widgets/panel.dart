import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import 'coin_counter.dart';
import 'game_button.dart';
import 'scenic_background.dart';

/// Cream cartoon panel with a thick outline.
class CartoonPanel extends StatelessWidget {
  const CartoonPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.panel,
    this.borderColor = AppColors.ink,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}

/// Standard menu screen: scenic background, title bar with back button and
/// currency balances, and content.
class MenuScaffold extends StatelessWidget {
  const MenuScaffold({super.key, required this.title, required this.child, this.showGems = true, this.onAddCoins, this.bottom});

  final String title;
  final Widget child;
  final bool showGems;
  final VoidCallback? onAddCoins;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: ScenicBackground(
        dim: 0.25,
        showHills: true,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    RoundIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).maybePop()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title, style: AppText.title(30), overflow: TextOverflow.ellipsis),
                    ),
                    ListenableBuilder(
                      listenable: s.progress,
                      builder: (context, _) => Row(
                        children: [
                          CurrencyPill(amount: s.progress.coins, onAdd: onAddCoins),
                          if (showGems) ...[const SizedBox(width: 8), CurrencyPill(amount: s.progress.gems, gem: true)],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showMessage(BuildContext context, String text, {bool good = true}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      content: Text(text, style: AppText.label(16)),
      backgroundColor: good ? AppColors.grassDark : AppColors.red,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Simple cartoon dialog.
Future<T?> showCartoonDialog<T>(BuildContext context, {required String title, required Widget body, List<Widget> actions = const []}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: const Color(0x99140A28),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, _) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Material(
                color: Colors.transparent,
                child: CartoonPanel(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppText.title(26, color: AppColors.orange),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Flexible(child: SingleChildScrollView(child: body)),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(spacing: 12, runSpacing: 10, alignment: WrapAlignment.center, children: actions),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
