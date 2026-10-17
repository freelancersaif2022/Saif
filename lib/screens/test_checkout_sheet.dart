import 'package:flutter/material.dart';

import '../services/iap/iap_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/ui.dart';

/// TEST MODE ONLY: replaces Google Play's checkout when the store is not
/// reachable, so purchase delivery can be tested offline. No money moves.
class TestCheckoutSheet extends StatelessWidget {
  const TestCheckoutSheet({super.key, required this.product, required this.price});
  final ProductInfo product;
  final String price;

  static Future<bool> open(ProductInfo product, String price) async {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return false;
    final r = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => TestCheckoutSheet(product: product, price: price),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF201A3D),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    'TEST PURCHASE',
                    style: TextStyle(fontFamily: 'Lilita', color: Colors.black, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('No real money will be charged', style: AppText.small)),
              ],
            ),
            const SizedBox(height: 16),
            Text(product.title, style: AppText.h1),
            const SizedBox(height: 4),
            Text(product.subtitle, style: AppText.body),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Price', style: AppText.label.copyWith(color: AppColors.textDim)),
                const Spacer(),
                Text(price, style: AppText.h2.copyWith(color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 18),
            GameButton(label: 'Confirm test purchase', icon: Icons.lock_open_rounded, color: AppColors.success, expand: true, onTap: () => Navigator.pop(context, true)),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: AppText.label.copyWith(color: AppColors.textDim)),
              ),
            ),
            Text('Real Google Play checkout appears here once the app is published and products are set up in Play Console.', style: AppText.small.copyWith(color: AppColors.textMute, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
