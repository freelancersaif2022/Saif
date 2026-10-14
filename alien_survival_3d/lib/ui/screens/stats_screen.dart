import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../progression/catalog.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final st = state.save.stats;
    final tiles = <(String, String, IconData)>[
      ('GAMES PLAYED', '${st.gamesPlayed}', Icons.sports_esports),
      ('TOTAL KILLS', '${st.totalKills}', Icons.dangerous),
      ('BEST WAVE', '${st.bestWave}', Icons.waves),
      ('BOSSES KILLED', '${st.bossesKilled}', Icons.whatshot),
      ('HEADSHOTS', '${st.totalHeadshots}', Icons.center_focus_strong),
      ('ACCURACY', '${(st.accuracy * 100).toStringAsFixed(1)}%', Icons.gps_fixed),
      ('TIME SURVIVED', formatDuration(st.totalSeconds), Icons.timer),
      ('BEST COMBO', 'x${st.bestCombo.toStringAsFixed(2)}', Icons.bolt),
      ('COINS EARNED', '${st.coinsEarned}', Icons.monetization_on),
      ('GEMS EARNED', '${st.gemsEarned}', Icons.diamond),
      ('PICKUPS', '${st.pickups}', Icons.inventory_2),
      ('GRENADES', '${st.grenadesThrown}', Icons.sports_handball),
    ];
    return SubScreen(
      title: 'STATISTICS',
      child: ListView(children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (name, value, icon) in tiles)
            SizedBox(
              width: 170,
              child: Panel(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Icon(icon, color: AppColors.lime, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(value, style: label.copyWith(fontSize: 18)),
                      Text(name, style: dim.copyWith(fontSize: 10)),
                    ]),
                  ),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        Text('ALIENS ELIMINATED', style: label.copyWith(color: AppColors.lime)),
        const SizedBox(height: 6),
        SizedBox(
          height: 150,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final a in aliens)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 112,
                  child: Panel(
                    padding: const EdgeInsets.all(6),
                    child: Column(children: [
                      Expanded(child: Image.asset('assets/images/alien_${a.id}.png', fit: BoxFit.contain)),
                      Text(a.name.toUpperCase(), style: label.copyWith(fontSize: 10, color: Color(a.color)), overflow: TextOverflow.ellipsis),
                      Text('${st.killsByType[a.id] ?? 0}', style: label.copyWith(fontSize: 16)),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}
