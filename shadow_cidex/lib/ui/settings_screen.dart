import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio.dart';
import '../core/save_data.dart';
import 'scene_painters.dart';
import 'theme.dart';
import 'widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin, SceneClock {
  late final BackdropPainter _painter = BackdropPainter(clock, tint: const Color(0xFF203050));

  void _toggle() {
    final on = !SaveData.instance.soundOn;
    GameAudio.instance.setEnabled(on);
    if (on) GameAudio.instance.play(Sfx.uiClick, volume: 0.8);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final on = SaveData.instance.soundOn;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, box) {
        final h = box.maxHeight;
        final w = box.maxWidth;
        final pw = math.min(520.0, w * 0.6);
        final unit = math.min(h / 720, w / 1280) * 1.25;
        return Stack(
          children: [
            Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _painter))),
            Center(
              child: SingleChildScrollView(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, k, child) => Opacity(
                    opacity: k,
                    child: Transform.scale(scale: 0.92 + 0.08 * k, child: child),
                  ),
                  child: SizedBox(
                    width: pw,
                    child: GlassPanel(
                      padding: EdgeInsets.symmetric(horizontal: 34 * unit, vertical: 26 * unit),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('SETTINGS', style: UiText.title(34 * unit, glow: 0.5)),
                          SizedBox(height: 26 * unit),
                          GestureDetector(
                            onTap: _toggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(horizontal: 20 * unit, vertical: 16 * unit),
                              decoration: BoxDecoration(
                                color: const Color(0xAA05070C),
                                border: Border.all(color: (on ? UiColors.accent : UiColors.locked).withAlpha(160), width: 1.4),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [if (on) BoxShadow(color: UiColors.accent.withAlpha(50), blurRadius: 18)],
                              ),
                              child: Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                                    child: Icon(
                                      on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                      key: ValueKey(on),
                                      size: 34 * unit,
                                      color: on ? UiColors.accent : UiColors.dim,
                                    ),
                                  ),
                                  SizedBox(width: 16 * unit),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text('SOUND: ${on ? 'ON' : 'OFF'}', style: UiText.heading(22 * unit)),
                                    ),
                                  ),
                                  _Switch(on: on, unit: unit),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10 * unit),
                          Text('MUSIC AND SOUND EFFECTS', style: UiText.body(15 * unit, color: UiColors.dim)),
                          SizedBox(height: 28 * unit),
                          CinematicButton(
                            label: 'BACK',
                            width: 220 * unit,
                            height: 52 * unit,
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.on, required this.unit});
  final bool on;
  final double unit;

  @override
  Widget build(BuildContext context) {
    final w = 64 * unit;
    final hh = 30 * unit;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: w,
      height: hh,
      decoration: BoxDecoration(
        color: on ? UiColors.accentDeep.withAlpha(120) : const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(hh / 2),
        border: Border.all(color: on ? UiColors.accent : UiColors.locked),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: hh - 6,
          height: hh - 6,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? UiColors.accent : UiColors.dim,
            boxShadow: [if (on) BoxShadow(color: UiColors.accent.withAlpha(140), blurRadius: 10)],
          ),
        ),
      ),
    );
  }
}
