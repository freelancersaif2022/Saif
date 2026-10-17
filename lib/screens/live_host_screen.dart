import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app.dart';
import '../game/battle_session.dart';
import '../models/monster.dart';
import '../net/live_link.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';
import 'battle_screen.dart';

/// Hosts a live room: shows the join QR and waits for the friend.
class LiveHostScreen extends StatefulWidget {
  const LiveHostScreen({super.key, required this.fighter});
  final Monster fighter;

  @override
  State<LiveHostScreen> createState() => _LiveHostScreenState();
}

class _LiveHostScreenState extends State<LiveHostScreen> {
  LiveHost? _host;
  LiveInvite? _invite;
  String? _error;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    setState(() {
      _error = null;
      _invite = null;
    });
    try {
      final host = await LiveNet.host();
      if (_closed) {
        await host.close();
        return;
      }
      if (host.addresses.isEmpty) {
        await host.close();
        setState(() => _error = 'Turn on Wi-Fi (or your hotspot) so your friend can connect.');
        return;
      }
      final nonce = Random().nextInt(1 << 31).toRadixString(36);
      _host = host;
      setState(() => _invite = LiveInvite(addresses: host.addresses, port: host.port, monsterCode: widget.fighter.toChallengeCode(), nonce: nonce));
      final session = await LiveSession.asHost(host, widget.fighter, nonce);
      if (_closed || !mounted) {
        await session.dispose();
        return;
      }
      Sfx.play(Fx.levelup);
      Sfx.haptic(heavy: true);
      final friend = session.foe.monster;
      AppToast.show('${friend.name} joined! Battle starts now.', type: ToastType.success, title: 'Friend connected');
      await Navigator.of(context).pushReplacement(gameRoute(BattleScreen(session: session, player: widget.fighter, enemy: friend, mode: BattleMode.live)));
    } catch (e) {
      if (_closed || !mounted) return;
      setState(() => _error = 'The connection failed. Make sure both phones are on the same Wi-Fi or hotspot, then try again.');
    }
  }

  @override
  void dispose() {
    _closed = true;
    _host?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invite = _invite;
    return Scaffold(
      appBar: AppBar(title: const Text('Live Battle Room')),
      extendBodyBehindAppBar: true,
      body: GameBackground(
        tint: AppColors.danger,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 66, 20, 30),
            children: [
              Center(child: MonsterView(monster: widget.fighter, size: 150)),
              Center(child: Text(widget.fighter.name, style: AppText.h1)),
              const SizedBox(height: 14),
              if (_error != null) ...[
                Panel(
                  borderColor: AppColors.danger.withValues(alpha: 0.6),
                  child: Column(
                    children: [
                      const IconBadge(icon: Icons.wifi_off_rounded, color: AppColors.danger),
                      const SizedBox(height: 10),
                      Text(_error!, textAlign: TextAlign.center, style: AppText.body),
                      const SizedBox(height: 14),
                      GameButton(label: 'Try again', icon: Icons.refresh_rounded, onTap: _open),
                    ],
                  ),
                ),
              ] else if (invite == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.danger),
                  ),
                )
              else ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: AppColors.danger.withValues(alpha: 0.4), blurRadius: 30)],
                    ),
                    child: QrImageView(data: invite.encode(), size: 230, padding: EdgeInsets.zero, backgroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const _Waiting(),
                const SizedBox(height: 16),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to join', style: AppText.h3),
                      const SizedBox(height: 8),
                      _Step(1, 'Both phones on the same Wi-Fi, or your friend connects to your hotspot.'),
                      _Step(2, 'Friend opens Arena → Live Battle → Join.'),
                      _Step(3, 'They scan this QR. The battle starts instantly!'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: invite.encode()));
                      AppToast.show('Room code copied. Your friend can paste it in "Enter Code".', type: ToastType.success);
                    },
                    icon: const Icon(Icons.copy_rounded, color: AppColors.cyan, size: 18),
                    label: Text('Copy room code instead', style: AppText.label.copyWith(color: AppColors.cyan)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Waiting extends StatefulWidget {
  const _Waiting();
  @override
  State<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends State<_Waiting> {
  int _dots = 0;
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 450), (_) => setState(() => _dots = (_dots + 1) % 4));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger)),
      const SizedBox(width: 10),
      Text('Waiting for your friend${'.' * _dots}', style: AppText.h3),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.text);
  final int n;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
          child: Text(
            '$n',
            style: AppText.small.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppText.small.copyWith(color: AppColors.text)),
        ),
      ],
    ),
  );
}
