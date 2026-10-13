import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../models/dragon_model.dart';
import '../widgets/dragon_card.dart';
import '../widgets/panel.dart';

/// Grid of all five dragons with prices, lock state and purchase flow.
class DragonShopScreen extends StatelessWidget {
  const DragonShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuScaffold(
      title: 'DRAGON SHOP',
      onAddCoins: () => Routes.coinShop(context),
      child: LayoutBuilder(
        builder: (context, box) {
          final cardW = ((box.maxWidth - 24 - 4 * 10) / 5).clamp(120.0, 240.0);
          return Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  for (final d in Dragons.all)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: cardW,
                        height: (box.maxHeight - 20).clamp(200.0, 340.0),
                        child: DragonCard(dragon: d, onTap: () => showDragonDetails(context, d)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
