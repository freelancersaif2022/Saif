import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';
import 'legal_screen.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _rates = [(0.35, 'Slow'), (0.45, 'Normal'), (0.55, 'Fast')];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: GC.ground,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 10, 20, pad.bottom + 30),
        children: [
          Row(children: [
            GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 18),
          Text('Settings', style: GC.display(32)),
          const SizedBox(height: 22),

          // Plan.
          _Card(children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: GC.amberDeep, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.workspace_premium_rounded, color: GC.amber),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.premium ? 'Ghost City Plus' : 'Free plan',
                          style: GC.body(16, color: GC.text, weight: FontWeight.w700, height: 1.2)),
                      const SizedBox(height: 3),
                      Text(
                          state.premium
                              ? switch (state.plan) {
                                  'life' => 'Lifetime plan · active',
                                  'month' => 'Monthly plan · active',
                                  _ => 'Yearly plan · active',
                                }
                              : 'Upgrade for every story, walk and Ghost mode.',
                          style: GC.body(13, color: GC.muted, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (state.premium)
              GhostButton(
                label: 'Manage Plus',
                icon: Icons.workspace_premium_outlined,
                height: 46,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen())),
              )
            else
              PrimaryButton(
                label: 'Purchase Plus',
                height: 46,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen())),
              ),
          ]),
          const SizedBox(height: 22),
          const SectionLabel('Narration speed'),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final r in _rates) ...[
                ChoiceChipX(
                  label: r.$2,
                  selected: (state.speechRate - r.$1).abs() < 0.01,
                  solid: true,
                  onTap: () => state.setSpeechRate(r.$1),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 26),
          const SectionLabel('Your data'),
          const SizedBox(height: 10),
          _Card(children: [
            _Row(icon: Icons.mic_none_rounded, title: 'Memories', value: '${state.memories.length}'),
            const Divider(height: 22, color: GC.line),
            _Row(icon: Icons.bookmark_border_rounded, title: 'Saved places', value: '${state.savedPlaces.length}'),
          ]),
          const SizedBox(height: 26),
          const SectionLabel('About'),
          const SizedBox(height: 10),
          _Card(children: [
            _LinkRow(icon: Icons.privacy_tip_outlined, title: 'Privacy policy', doc: LegalDoc.privacy),
            const Divider(height: 22, color: GC.line),
            _LinkRow(icon: Icons.gavel_rounded, title: 'Terms & conditions', doc: LegalDoc.terms),
            const Divider(height: 22, color: GC.line),
            _LinkRow(icon: Icons.copyright_rounded, title: 'Licences', doc: LegalDoc.licences),
          ]),
          const SizedBox(height: 20),
          Center(child: Text('Ghost City 1.0.0', style: GC.body(12, color: GC.faint))),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GC.surface,
        borderRadius: BorderRadius.circular(GC.radiusL),
        border: Border.all(color: GC.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.title, required this.doc});
  final IconData icon;
  final String title;
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LegalScreen(doc: doc))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: GC.muted, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: GC.body(15, color: GC.text, height: 1.2))),
            const Icon(Icons.chevron_right_rounded, color: GC.faint),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: GC.muted, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: GC.body(15, color: GC.text, height: 1.2))),
        Text(value, style: GC.body(14, color: GC.muted, height: 1.2)),
      ],
    );
  }
}
