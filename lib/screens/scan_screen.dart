import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/monster.dart';
import '../net/live_link.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';

/// Scans a friend's challenge QR. Decoding happens on-device (offline).
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _handled = false;
  DateTime _lastInvalid = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      // Returns the raw code: a live-room invite or a beast challenge.
      if (LiveInvite.decode(raw) != null || Monster.fromChallengeCode(raw) != null) {
        _handled = true;
        Sfx.play(Fx.coin);
        Sfx.haptic();
        Navigator.of(context).pop(raw);
        return;
      }
    }
    if (DateTime.now().difference(_lastInvalid) > const Duration(seconds: 3)) {
      _lastInvalid = DateTime.now();
      AppToast.show('This QR is not a VoiceBeast challenge.', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Challenge QR'),
        actions: [IconButton(onPressed: () => _controller.toggleTorch(), icon: const Icon(Icons.flashlight_on_rounded))],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (c, err) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconBadge(icon: Icons.no_photography_rounded, color: AppColors.danger),
                      const SizedBox(height: 14),
                      Text('Camera unavailable', style: AppText.h1),
                      const SizedBox(height: 8),
                      Text(
                        err.errorCode == MobileScannerErrorCode.permissionDenied
                            ? 'Allow camera access in Settings to scan QR codes, or use "Enter Code" instead.'
                            : 'Could not start the camera. Use "Enter Code" instead.',
                        textAlign: TextAlign.center,
                        style: AppText.body,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: const [BoxShadow(color: Color(0x88000000), spreadRadius: 2000)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Text("Point at your friend's beast QR", textAlign: TextAlign.center, style: AppText.h3),
          ),
        ],
      ),
    );
  }
}
