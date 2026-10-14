import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../audio/menu_audio.dart';
import '../../progression/game_state.dart';
import '../../storage/models.dart';
import '../widgets.dart';

/// Audio, graphics, camera and control settings. Changes are saved
/// immediately. [onChanged] lets the in-game pause menu push them live.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state, this.onChanged, this.inGame = false});

  final GameState state;
  final void Function(Settings s)? onChanged;
  final bool inGame;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Settings get s => widget.state.settings;

  void _changed() {
    setState(() {});
    widget.state.persistSettings();
    MenuAudio.instance.refreshVolumes();
    widget.onChanged?.call(s);
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: label.copyWith(color: AppColors.lime, fontSize: 15)),
            const SizedBox(height: 4),
            ...children,
          ]),
        ),
      );

  Widget _slider(String name, double value, double min, double max, void Function(double) set, {String Function(double)? fmt, int? divisions}) => Row(children: [
        SizedBox(width: 170, child: Text(name, style: label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (v) => setState(() => set(v)),
            onChangeEnd: (_) => _changed(),
          ),
        ),
        SizedBox(width: 56, child: Text(fmt != null ? fmt(value) : '${(value * 100).round()}%', textAlign: TextAlign.right, style: label)),
      ]);

  Widget _toggle(String name, bool value, void Function(bool) set) => Row(children: [
        Expanded(child: Text(name, style: label)),
        Switch(value: value, onChanged: (v) {
          set(v);
          _changed();
        }),
      ]);

  Widget _choice<T>(String name, T value, List<(T, String)> options, void Function(T) set, {String? note}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 170, child: Text(name, style: label)),
          Expanded(
            child: Wrap(spacing: 8, runSpacing: 6, children: [
              for (final (v, text) in options)
                NeonButton(
                  key: Key('opt_${name}_$text'),
                  label: text,
                  primary: v == value,
                  height: 34,
                  fontSize: 12,
                  onPressed: () {
                    set(v);
                    _changed();
                  },
                ),
              if (note != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(note, style: dim)),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    String pct(double v) => '${(v * 100).round()}%';
    return SubScreen(
      title: 'SETTINGS',
      child: ListView(children: [
        _section('AUDIO', [
          _slider('Master', s.masterVolume, 0, 1, (v) => s.masterVolume = v, fmt: pct),
          _slider('Music', s.musicVolume, 0, 1, (v) => s.musicVolume = v, fmt: pct),
          _slider('Effects', s.sfxVolume, 0, 1, (v) => s.sfxVolume = v, fmt: pct),
          _slider('Ambience', s.ambienceVolume, 0, 1, (v) => s.ambienceVolume = v, fmt: pct),
        ]),
        _section('GRAPHICS', [
          _choice<Quality>('Quality', s.quality, [(Quality.LOW, 'LOW'), (Quality.MEDIUM, 'MEDIUM'), (Quality.HIGH, 'HIGH')], (v) => s.quality = v,
              note: widget.inGame ? 'Applies to the next game.' : null),
          _choice<int>('Frame rate', s.fps, [(30, '30 FPS'), (60, '60 FPS')], (v) => s.fps = v),
          _toggle('Show FPS counter', s.showFps, (v) => s.showFps = v),
        ]),
        _section('CAMERA & AIM', [
          _slider('Look sensitivity', s.sensitivity, 0.2, 3, (v) => s.sensitivity = v, fmt: (v) => v.toStringAsFixed(2)),
          _slider('Aim sensitivity', s.aimSensitivity, 0.1, 1.5, (v) => s.aimSensitivity = v, fmt: (v) => v.toStringAsFixed(2)),
          _slider('Field of view', s.fov, 55, 95, (v) => s.fov = v.roundToDouble(), fmt: (v) => '${v.round()}°', divisions: 40),
          _slider('Camera shake', s.cameraShake, 0, 1.5, (v) => s.cameraShake = v, fmt: pct),
          _choice<int>('Camera shoulder', s.shoulder, [(1, 'RIGHT'), (-1, 'LEFT')], (v) => s.shoulder = v),
          _toggle('Invert vertical look', s.invertY, (v) => s.invertY = v),
          _toggle('Aim assist', s.aimAssist, (v) => s.aimAssist = v),
        ]),
        _section('TOUCH CONTROLS', [
          _slider('Button size', s.controlScale, 0.6, 1.5, (v) => s.controlScale = v, fmt: pct),
          _slider('Button opacity', s.controlOpacity, 0.3, 1, (v) => s.controlOpacity = v, fmt: pct),
          _toggle('Vibration', s.vibration, (v) => s.vibration = v),
          const SizedBox(height: 6),
          if (!widget.inGame)
            Row(children: [
              NeonButton(key: const Key('editLayout'), label: 'EDIT CONTROL LAYOUT', icon: Icons.open_with, height: 40, onPressed: () => Navigator.of(context).pushNamed(Routes.layoutEditor)),
              const SizedBox(width: 10),
              NeonButton(
                label: 'RESET LAYOUT',
                height: 40,
                onPressed: s.layout.isEmpty
                    ? null
                    : () {
                        s.layout = {};
                        _changed();
                        showMessage(context, 'Control layout reset');
                      },
              ),
            ]),
        ]),
        if (!widget.inGame)
          _section('DATA', [
            Text('All progress is stored only on this device. The game works fully offline, with no ads, tracking or analytics.', style: dim),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: NeonButton(
                label: 'RESET PROGRESS',
                icon: Icons.delete_forever,
                height: 40,
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset all progress?'),
                      content: const Text('Coins, gems, weapons, upgrades, high scores and statistics will be deleted. Settings are kept.'),
                      actions: [
                        NeonButton(label: 'CANCEL', height: 38, onPressed: () => Navigator.of(ctx).pop(false)),
                        NeonButton(label: 'RESET', primary: true, height: 38, onPressed: () => Navigator.of(ctx).pop(true)),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await widget.state.resetProgress();
                    if (context.mounted) showMessage(context, 'Progress reset');
                  }
                },
              ),
            ),
          ]),
      ]),
    );
  }
}
