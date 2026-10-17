import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/monster.dart';
import '../services/roar_storage.dart';
import '../theme/app_theme.dart';
import 'feedback.dart';
import 'monster_view.dart';
import 'ui.dart';

const _storeLink = 'https://play.google.com/store/apps/details?id=com.voicebeast.arena';

/// Social-media card (4:5, Instagram friendly) with a scannable challenge QR.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.monster});
  final Monster monster;

  @override
  Widget build(BuildContext context) {
    final e = monster.element;
    return Container(
      width: 360,
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [e.color.withValues(alpha: 0.85), e.deep, AppColors.bg0], stops: const [0, 0.5, 1]),
        border: Border.all(color: monster.rarity.color, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('VOICEBEAST ARENA', style: AppText.h3.copyWith(letterSpacing: 3, color: Colors.white.withValues(alpha: 0.9))),
                Text('Born from my voice!', style: AppText.small.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(child: MonsterView(monster: monster, size: 250, animate: false)),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(monster.name, style: AppText.display.copyWith(fontSize: 30), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RarityTag(monster.rarity),
                          const SizedBox(width: 6),
                          ElementBadge(e, compact: true),
                          const SizedBox(width: 6),
                          Text('Lv ${monster.level}', style: AppText.h3),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('HP ${monster.maxHp} • ATK ${monster.atk}\nDEF ${monster.def} • SPD ${monster.spd}', style: AppText.label.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('POWER ${monster.power}', style: AppText.h2.copyWith(color: AppColors.gold)),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: QrImageView(data: monster.toChallengeCode(), size: 96, padding: EdgeInsets.zero, backgroundColor: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text('Scan to battle me!', style: AppText.small.copyWith(color: Colors.white, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShareService {
  ShareService._();

  static Future<void> showCardPreview(BuildContext context, Monster monster) async {
    final key = GlobalKey();
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'share',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (_, a, _, c) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
          child: c,
        ),
      ),
      pageBuilder: (c, _, _) => SafeArea(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  child: RepaintBoundary(
                    key: key,
                    child: ShareCard(monster: monster),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 330,
                  child: Row(
                    children: [
                      Expanded(
                        child: GameButton(label: 'Close', color: AppColors.surfaceHi, small: true, onTap: () => Navigator.pop(c)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GameButton(label: 'Share Card', icon: Icons.share_rounded, color: AppColors.success, small: true, onTap: () => _shareBoundary(key, monster)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _shareBoundary(GlobalKey key, Monster monster) async {
    try {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();
      final fileName = 'voicebeast_${monster.name.toLowerCase()}.png';
      XFile file;
      if (kIsWeb) {
        file = XFile.fromData(bytes, mimeType: 'image/png', name: fileName);
      } else {
        final path = await RoarStorage.writeTemp(fileName, bytes);
        file = XFile(path!, mimeType: 'image/png');
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: 'My voice created ${monster.name}, a ${monster.rarity.label} ${monster.element.label} beast! 🔥 Can you beat it? Scan the QR in VoiceBeast Arena.\n$_storeLink',
        ),
      );
    } catch (e) {
      debugPrint('Share failed: $e');
      AppToast.show('Could not share the card. Please try again.', type: ToastType.error);
    }
  }

  static Future<void> shareRoar(Monster monster) async {
    final path = monster.roarPath;
    if (path == null || path.startsWith('mem:')) {
      AppToast.show('This beast has no saved roar to share.', type: ToastType.info);
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'audio/wav')],
          text: 'This roar created ${monster.name} in VoiceBeast Arena 🎤👹\n$_storeLink',
        ),
      );
    } catch (e) {
      AppToast.show('Could not share the roar.', type: ToastType.error);
    }
  }

  static Future<void> showChallengeQr(BuildContext context, Monster monster) async {
    final code = monster.toChallengeCode();
    await AppDialog.show(
      context: context,
      title: 'Challenge QR',
      message: 'Friends scan this in Arena → Challenge a Friend.',
      accent: monster.element.color,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: QrImageView(data: code, size: 210, padding: EdgeInsets.zero, backgroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          Pressable(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: code));
              AppToast.show('Challenge code copied. Paste it in any chat!', type: ToastType.success, title: 'Copied');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy_rounded, size: 18, color: AppColors.cyan),
                ],
              ),
            ),
          ),
        ],
      ),
      primaryLabel: 'Send Code',
      primaryIcon: Icons.send_rounded,
      onPrimary: () => SharePlus.instance.share(
        ShareParams(
          text: '⚔️ I challenge you in VoiceBeast Arena! My beast ${monster.name} (Lv ${monster.level}) is waiting.\nOpen Arena → Challenge a Friend → Enter code:\n$code\n\nGet the game: $_storeLink',
        ),
      ),
      secondaryLabel: 'Close',
    );
  }
}
