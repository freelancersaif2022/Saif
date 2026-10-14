import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';

class HighScoresScreen extends StatelessWidget {
  const HighScoresScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final list = state.save.highScores;
    return SubScreen(
      title: 'HIGH SCORES',
      child: list.isEmpty
          ? Center(child: Text('No runs yet. Survive a wave to set a record!', style: label.copyWith(color: AppColors.textDim)))
          : Panel(
              child: Column(children: [
                _row(context, '#', 'SCORE', 'WAVE', 'KILLS', 'TIME', 'DATE', header: true),
                const Divider(color: AppColors.panelBorder, height: 8),
                Expanded(
                  child: ListView(children: [
                    for (var i = 0; i < list.length; i++)
                      _row(
                        context,
                        '${i + 1}',
                        '${list[i].score}',
                        '${list[i].wave}',
                        '${list[i].kills}',
                        formatDuration(list[i].seconds),
                        '${list[i].date.year}-${list[i].date.month.toString().padLeft(2, '0')}-${list[i].date.day.toString().padLeft(2, '0')}',
                        gold: i == 0,
                      ),
                  ]),
                ),
              ]),
            ),
    );
  }

  Widget _row(BuildContext context, String a, String b, String c, String d, String e, String f, {bool header = false, bool gold = false}) {
    final st = header ? dim.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1) : label.copyWith(fontSize: 15, color: gold ? AppColors.lime : AppColors.text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 40, child: Text(a, style: st)),
        Expanded(flex: 3, child: Text(b, style: st)),
        Expanded(flex: 2, child: Text(c, style: st)),
        Expanded(flex: 2, child: Text(d, style: st)),
        Expanded(flex: 2, child: Text(e, style: st)),
        Expanded(flex: 3, child: Text(f, style: st, textAlign: TextAlign.right)),
      ]),
    );
  }
}
