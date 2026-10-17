import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/feedback.dart';

/// TEST MODE ONLY: stands in for a real ad when no ad could be loaded
/// (offline / emulator). Lets every reward flow be tested end-to-end.
class SimulatedAdScreen extends StatefulWidget {
  const SimulatedAdScreen({super.key, required this.rewarded, this.rewardLabel});
  final bool rewarded;
  final String? rewardLabel;

  static Future<bool> open({required bool rewarded, String? rewardLabel}) async {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return false;
    final r = await nav.push<bool>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => SimulatedAdScreen(rewarded: rewarded, rewardLabel: rewardLabel),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ),
    );
    return r ?? false;
  }

  @override
  State<SimulatedAdScreen> createState() => _SimulatedAdScreenState();
}

class _SimulatedAdScreenState extends State<SimulatedAdScreen> {
  late int _left = widget.rewarded ? 5 : 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _close() async {
    if (_left > 0 && widget.rewarded) {
      final leave = await AppDialog.confirm(
        context: context,
        title: 'Skip video?',
        message: 'You will lose ${widget.rewardLabel ?? 'the reward'}.',
        confirmLabel: 'Skip anyway',
        cancelLabel: 'Keep watching',
        icon: Icons.ondemand_video_rounded,
      );
      if (!leave || !mounted) return;
      Navigator.of(context).pop(false);
      return;
    }
    Navigator.of(context).pop(widget.rewarded ? _left <= 0 : true);
  }

  @override
  Widget build(BuildContext context) {
    final done = _left <= 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(6)),
                      child: const Text(
                        'TEST AD',
                        style: TextStyle(fontFamily: 'Lilita', color: Colors.black, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Icon(widget.rewarded ? Icons.card_giftcard_rounded : Icons.campaign_rounded, size: 72, color: AppColors.gold),
                    const SizedBox(height: 14),
                    Text(widget.rewarded ? 'Rewarded video' : 'Interstitial ad', style: AppText.h1),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text('Simulated because no real ad could load (offline or test device).\nReal AdMob ads appear here when online.', textAlign: TextAlign.center, style: AppText.small),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(value: done ? 1 : 1 - _left / (widget.rewarded ? 5 : 3), strokeWidth: 5, color: AppColors.gold, backgroundColor: Colors.white12),
                          Text(done ? '✓' : '$_left', style: AppText.h2),
                        ],
                      ),
                    ),
                    if (done && widget.rewarded) ...[const SizedBox(height: 16), Text('Reward unlocked: ${widget.rewardLabel ?? ''}', style: AppText.label.copyWith(color: AppColors.gold))],
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: (done || widget.rewarded) ? _close : null,
                  icon: Icon(Icons.close_rounded, color: done ? Colors.white : Colors.white24, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
