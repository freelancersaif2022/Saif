import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';
import '../../audio/menu_audio.dart';
import '../../engine/game_bridge.dart';
import '../../progression/game_state.dart';

/// Opens the engine in layout mode: every touch control can be dragged to a
/// new place over the live 3D view. DONE saves and returns.
class LayoutEditorScreen extends StatefulWidget {
  const LayoutEditorScreen({super.key, required this.state});

  final GameState state;

  @override
  State<LayoutEditorScreen> createState() => _LayoutEditorScreenState();
}

class _LayoutEditorScreenState extends State<LayoutEditorScreen> {
  late final GameBridge bridge;
  bool ready = false;
  bool webReady = false;

  @override
  void initState() {
    super.initState();
    MenuAudio.instance.pauseAll();
    final cfg = widget.state.engineConfig(mode: 'layout');
    // keep the editor quiet and light
    (cfg['settings'] as Map<String, Object?>)['quality'] = 'LOW';
    (cfg['settings'] as Map<String, Object?>)['musicVolume'] = 0;
    bridge = GameBridge(config: cfg, onEvent: _onEvent);
    bridge.init().then((_) {
      if (mounted) setState(() => webReady = true);
    });
  }

  void _onEvent(EngineEvent e) {
    switch (e) {
      case EngineReady():
        setState(() => ready = true);
      case EngineLayout(:final layout, :final done):
        widget.state.settings.layout = layout;
        widget.state.persistSettings();
        if (done && mounted) Navigator.of(context).pop();
      default:
        break;
    }
  }

  @override
  void dispose() {
    bridge.quit();
    MenuAudio.instance.resumeMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(fit: StackFit.expand, children: [
        if (webReady) WebViewWidget(controller: bridge.controller),
        if (!ready) const Center(child: CircularProgressIndicator(color: AppColors.lime)),
      ]),
    );
  }
}
