import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../models/player_progress_model.dart';
import '../services/purchase_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/game_button.dart';
import '../widgets/panel.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MenuScaffold(
      title: 'SETTINGS',
      bottom: const BannerAdSlot(),
      child: ListenableBuilder(
        listenable: s.progress,
        builder: (context, _) {
          final st = s.progress.settings;
          void change(void Function(GameSettings g) f) {
            s.progress.updateSettings(f);
            s.audio.applySettings(s.progress.settings);
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CartoonPanel(
                    child: ListView(
                      children: [
                        _toggle('Music', Icons.music_note_rounded, st.music, (v) => change((g) => g.music = v)),
                        _slider('Music volume', st.musicVolume, st.music, (v) => change((g) => g.musicVolume = v)),
                        _toggle('Sound effects', Icons.volume_up_rounded, st.sound, (v) => change((g) => g.sound = v)),
                        _slider('Sound volume', st.soundVolume, st.sound, (v) => change((g) => g.soundVolume = v)),
                        _toggle('Vibration', Icons.vibration_rounded, st.vibration, (v) => change((g) => g.vibration = v)),
                        _toggle('Left-handed controls', Icons.swap_horiz_rounded, st.leftHanded, (v) => change((g) => g.leftHanded = v)),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.purple),
                              const SizedBox(width: 10),
                              Text('Graphics', style: AppText.label(16, color: AppColors.ink)),
                              const Spacer(),
                              SegmentedButton<GraphicsQuality>(
                                segments: const [
                                  ButtonSegment(value: GraphicsQuality.low, label: Text('Low')),
                                  ButtonSegment(value: GraphicsQuality.medium, label: Text('Medium')),
                                  ButtonSegment(value: GraphicsQuality.high, label: Text('High')),
                                ],
                                selected: {st.graphics},
                                showSelectedIcon: false,
                                onSelectionChanged: (v) => change((g) => g.graphics = v.first),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 270,
                  child: CartoonPanel(
                    child: ListView(
                      children: [
                        GameButton(
                          label: s.progress.adsRemoved ? 'ADS REMOVED' : 'REMOVE ADS',
                          icon: Icons.block_rounded,
                          color: AppColors.red,
                          height: 46,
                          fontSize: 17,
                          onPressed: s.progress.adsRemoved ? null : () => Routes.coinShop(context, tab: 3),
                        ),
                        const SizedBox(height: 8),
                        GameButton(
                          label: 'RESTORE PURCHASES',
                          icon: Icons.restore_rounded,
                          color: AppColors.skyDeep,
                          height: 46,
                          fontSize: 16,
                          cooldown: const Duration(seconds: 3),
                          onPressed: () {
                            if (s.purchases.state != StoreState.ready) {
                              showMessage(context, s.purchases.storeError ?? 'Store not available.', good: false);
                              return;
                            }
                            s.purchases.restore();
                            showMessage(context, 'Restoring purchases...');
                          },
                        ),
                        const SizedBox(height: 8),
                        GameButton(
                          label: 'AD PRIVACY OPTIONS',
                          icon: Icons.privacy_tip_rounded,
                          color: AppColors.purple,
                          height: 46,
                          fontSize: 15,
                          onPressed: () => s.ads.showPrivacyOptions(),
                        ),
                        const SizedBox(height: 8),
                        GameButton(
                          label: 'PRIVACY POLICY',
                          icon: Icons.shield_outlined,
                          color: const Color(0xFF7D86A6),
                          height: 42,
                          fontSize: 15,
                          onPressed: () => Routes.legal(context, LegalPage.privacy),
                        ),
                        const SizedBox(height: 8),
                        GameButton(
                          label: 'TERMS OF SERVICE',
                          icon: Icons.description_outlined,
                          color: const Color(0xFF7D86A6),
                          height: 42,
                          fontSize: 15,
                          onPressed: () => Routes.legal(context, LegalPage.terms),
                        ),
                        const SizedBox(height: 8),
                        GameButton(
                          label: 'ABOUT',
                          icon: Icons.info_outline_rounded,
                          color: const Color(0xFF7D86A6),
                          height: 42,
                          fontSize: 15,
                          onPressed: () => Routes.legal(context, LegalPage.about),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toggle(String label, IconData icon, bool value, ValueChanged<bool> onChanged) => Row(
    children: [
      Icon(icon, color: AppColors.purple),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label, style: AppText.label(16, color: AppColors.ink)),
      ),
      Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.grass),
    ],
  );

  Widget _slider(String label, double value, bool enabled, ValueChanged<double> onChanged) => Row(
    children: [
      const SizedBox(width: 34),
      SizedBox(
        width: 110,
        child: Text(label, style: AppText.label(13, color: const Color(0xFF6B5A7A))),
      ),
      Expanded(
        child: Slider(value: value, onChanged: enabled ? onChanged : null, activeColor: AppColors.orange),
      ),
    ],
  );
}
