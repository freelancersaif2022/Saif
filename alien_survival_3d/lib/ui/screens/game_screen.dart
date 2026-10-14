import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../audio/menu_audio.dart';
import '../../engine/game_bridge.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';
import 'settings_screen.dart';

enum _Phase { loading, playing, paused, over, error }

/// Hosts the real-time 3D engine and the Flutter overlays around it.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.state});

  final GameState state;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final GameBridge bridge;
  bool _webReady = false;
  _Phase phase = _Phase.loading;
  double progress = 0;
  String error = '';
  RunResult? result;
  RunReward? reward;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MenuAudio.instance.stopMusic();
    bridge = GameBridge(config: widget.state.engineConfig(), onEvent: _onEvent);
    bridge.init().then((_) {
      if (mounted) setState(() => _webReady = true);
    }).catchError((Object e) {
      if (mounted) {
        setState(() {
          phase = _Phase.error;
          error = '$e';
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bridge.quit();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if ((s == AppLifecycleState.paused || s == AppLifecycleState.inactive || s == AppLifecycleState.hidden) && phase == _Phase.playing) {
      bridge.pause();
    }
  }

  Future<void> _onEvent(EngineEvent e) async {
    if (!mounted) return;
    switch (e) {
      case EngineLoading(:final progress):
        setState(() => this.progress = progress);
      case EngineReady():
        setState(() => phase = _Phase.playing);
      case EnginePaused():
        if (phase == _Phase.playing) setState(() => phase = _Phase.paused);
      case EngineResumed():
      case EngineRestarted():
        setState(() {
          phase = _Phase.playing;
          _showSettings = false;
        });
      case EngineGameOver(:final stats):
        final r = RunResult(stats);
        final rw = await widget.state.applyRun(r);
        if (!mounted) return;
        setState(() {
          result = r;
          reward = rw;
          phase = _Phase.over;
        });
      case EngineHaptic(:final heavy):
        if (widget.state.settings.vibration) heavy ? HapticFeedback.heavyImpact() : HapticFeedback.lightImpact();
      case EngineLayout(:final layout):
        widget.state.settings.layout = layout;
        widget.state.persistSettings();
      case EnginePerf():
        break;
      case EngineError(:final message):
        if (phase == _Phase.loading) {
          setState(() {
            phase = _Phase.error;
            error = message;
          });
        } else {
          debugPrint('engine error: $message');
        }
    }
  }

  void _resume() {
    bridge.resume();
    setState(() {
      phase = _Phase.playing;
      _showSettings = false;
    });
  }

  void _restart() {
    bridge.restart();
    setState(() {
      phase = _Phase.playing;
      result = null;
      reward = null;
      _showSettings = false;
    });
  }

  Future<void> _quit() async {
    await bridge.quit();
    if (mounted) Navigator.of(context).pop();
  }

  void _onBack() {
    switch (phase) {
      case _Phase.playing:
        bridge.pause();
        setState(() => phase = _Phase.paused);
      case _Phase.paused:
        if (_showSettings) {
          setState(() => _showSettings = false);
        } else {
          _resume();
        }
      case _Phase.loading:
      case _Phase.over:
      case _Phase.error:
        _quit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(fit: StackFit.expand, children: [
          if (_webReady) WebViewWidget(controller: bridge.controller),
          if (phase == _Phase.loading) _loading(),
          if (phase == _Phase.paused) _pause(),
          if (phase == _Phase.over) _gameOver(),
          if (phase == _Phase.error) _error(),
        ]),
      ),
    );
  }

  Widget _loading() => Container(
        color: AppColors.black,
        child: Stack(fit: StackFit.expand, children: [
          Opacity(opacity: 0.3, child: Image.asset('assets/images/menu_bg.jpg', fit: BoxFit.cover)),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('DEPLOYING', style: headline.copyWith(fontSize: 30, color: AppColors.lime)),
              const SizedBox(height: 14),
              SizedBox(width: 300, child: LinearProgressIndicator(value: progress > 0 ? progress : null, minHeight: 6, color: AppColors.lime, backgroundColor: const Color(0xFF1D241B))),
              const SizedBox(height: 10),
              Text('Building the forest, loading aliens and audio', style: dim),
            ]),
          ),
        ]),
      );

  Widget _scrim(Widget child) => Container(color: const Color(0xB3000000), alignment: Alignment.center, child: SafeArea(child: child));

  Widget _pause() {
    if (_showSettings) {
      return Container(
        color: AppColors.black,
        child: SettingsScreen(state: widget.state, inGame: true, onChanged: (s) => bridge.setSettings(s.toEngine())),
      );
    }
    return _scrim(SizedBox(
      width: 300,
      child: Panel(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('PAUSED', textAlign: TextAlign.center, style: headline.copyWith(fontSize: 30, color: AppColors.lime)),
          const SizedBox(height: 14),
          NeonButton(key: const Key('resume'), label: 'RESUME', primary: true, height: 52, fontSize: 20, onPressed: _resume),
          const SizedBox(height: 8),
          NeonButton(label: 'SETTINGS', icon: Icons.settings, onPressed: () => setState(() => _showSettings = true)),
          const SizedBox(height: 8),
          NeonButton(label: 'RESTART', icon: Icons.replay, onPressed: () async {
            final ok = await _confirm('Restart this run?', 'Progress in the current run will be lost.');
            if (ok) _restart();
          }),
          const SizedBox(height: 8),
          NeonButton(label: 'QUIT TO MENU', icon: Icons.home, onPressed: () async {
            final ok = await _confirm('Quit to menu?', 'The current run will end without rewards.');
            if (ok) _quit();
          }),
        ]),
      ),
    ));
  }

  Future<bool> _confirm(String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          NeonButton(label: 'NO', height: 38, onPressed: () => Navigator.of(ctx).pop(false)),
          NeonButton(label: 'YES', primary: true, height: 38, onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    return ok == true;
  }

  Widget _gameOver() {
    final r = result!, rw = reward!;
    Widget stat(String name, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [Expanded(child: Text(name, style: dim.copyWith(fontSize: 13))), Text(value, style: label.copyWith(fontSize: 15))]),
        );
    return _scrim(SizedBox(
      width: 560,
      child: Panel(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('GAME OVER', style: headline.copyWith(fontSize: 34, color: const Color(0xFFFF3B5C))),
          if (rw.newHighScore)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(4)),
              child: const Text('NEW HIGH SCORE!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
            ),
          const SizedBox(height: 8),
          Text('${r.score}', style: headline.copyWith(fontSize: 40, color: AppColors.lime)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(children: [
                stat('Wave reached', '${r.wave}'),
                stat('Aliens killed', '${r.kills}'),
                stat('Time survived', formatDuration(r.seconds)),
                stat('Accuracy', '${r.accuracy}%'),
                stat('Headshots', '${r.headshots}'),
              ]),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(children: [
                stat('Coins collected', '+${rw.coinsCollected}'),
                stat('Wave bonus', '+${rw.waveBonus}'),
                stat('Score bonus', '+${rw.scoreBonus}'),
                stat('Gems', '+${rw.gems}'),
                const Divider(color: AppColors.panelBorder),
                Row(children: [
                  const Icon(Icons.monetization_on, color: AppColors.gold, size: 20),
                  const SizedBox(width: 6),
                  Text('+${rw.totalCoins}', style: label.copyWith(fontSize: 18, color: AppColors.gold)),
                  const Spacer(),
                  if (rw.rank > 0) Text('RANK #${rw.rank}', style: label.copyWith(color: AppColors.lime)),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: NeonButton(key: const Key('again'), label: 'PLAY AGAIN', primary: true, height: 48, onPressed: _restart)),
            const SizedBox(width: 8),
            Expanded(
              child: NeonButton(label: 'UPGRADE', icon: Icons.upgrade, height: 48, onPressed: () async {
                await bridge.quit();
                if (mounted) Navigator.of(context).pushReplacementNamed(Routes.upgrade);
              }),
            ),
            const SizedBox(width: 8),
            Expanded(child: NeonButton(label: 'MAIN MENU', icon: Icons.home, height: 48, onPressed: _quit)),
          ]),
        ]),
      ),
    ));
  }

  Widget _error() => _scrim(SizedBox(
        width: 460,
        child: Panel(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('THE 3D ENGINE COULD NOT START', style: headline.copyWith(fontSize: 18, color: const Color(0xFFFF3B5C))),
            const SizedBox(height: 8),
            Text('This device needs WebGL 2 in Android System WebView. Update "Android System WebView" from the Play Store and try again.', style: dim, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(error, style: dim.copyWith(fontSize: 10), maxLines: 4, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            NeonButton(label: 'BACK TO MENU', primary: true, onPressed: _quit),
          ]),
        ),
      ));
}
