import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../progression/catalog.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';

/// Buy weapons with coins (and gems for the minigun). No real-money purchases.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final maxDmg = weapons.map((w) => w.damage * w.pellets).reduce((a, b) => a > b ? a : b);
    return SubScreen(
      title: 'SHOP',
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => GridView.extent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 1.05,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final w in weapons.where((w) => !w.sidearm))
              Panel(
                highlight: state.owns(w.id),
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text(w.name.toUpperCase(), style: label.copyWith(fontSize: 15))),
                    if (state.owns(w.id)) const Icon(Icons.check_circle, color: AppColors.lime, size: 18),
                  ]),
                  Expanded(child: Image.asset(w.image, fit: BoxFit.contain)),
                  StatBar(name: 'Damage', value: w.damage * w.pellets / maxDmg, display: '${w.damage.round()}${w.pellets > 1 ? '×${w.pellets}' : ''}'),
                  StatBar(name: 'Fire rate', value: w.roundsPerMinute / 1400, display: '${w.roundsPerMinute.round()}'),
                  StatBar(name: 'Range', value: w.range / 320, display: '${w.range.round()} m'),
                  const SizedBox(height: 6),
                  if (state.owns(w.id))
                    const NeonButton(label: 'OWNED', onPressed: null, height: 36, fontSize: 13)
                  else
                    NeonButton(
                      key: Key('buy_${w.id}'),
                      label: 'BUY  ${w.price}${w.gemPrice > 0 ? ' + ${w.gemPrice}♦' : ''}',
                      icon: Icons.monetization_on,
                      primary: state.save.coins >= w.price && state.save.gems >= w.gemPrice,
                      height: 36,
                      fontSize: 13,
                      sound: 'ui_select',
                      onPressed: () async {
                        final r = await state.buyWeapon(w.id);
                        if (context.mounted) showMessage(context, r == PurchaseResult.ok ? '${w.name} unlocked!' : purchaseMessage(r));
                      },
                    ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
