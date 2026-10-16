import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
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
                  child: const Icon(Icons.auto_awesome, color: GC.amber),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.premium ? 'Ghost City Plus' : 'Free plan',
                          style: GC.body(16, color: GC.text, weight: FontWeight.w700, height: 1.2)),
                      const SizedBox(height: 3),
                      Text(state.premium ? 'Everything is unlocked.' : 'Upgrade for every story, walk and Ghost mode.',
                          style: GC.body(13, color: GC.muted, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (state.premium)
              GhostButton(label: 'Turn off Plus (test mode)', height: 46, onPressed: () => state.setPremium(false))
            else
              PrimaryButton(
                label: 'See Plus',
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
            _Row(icon: Icons.phone_iphone_rounded, title: 'Account', value: 'Not needed'),
            const Divider(height: 22, color: GC.line),
            _Row(icon: Icons.mic_none_rounded, title: 'Memories', value: '${state.memories.length}'),
            const Divider(height: 22, color: GC.line),
            _Row(icon: Icons.bookmark_border_rounded, title: 'Saved places', value: '${state.saved.length}'),
          ]),
          const SizedBox(height: 12),
          GhostButton(
            label: 'Erase everything and restart',
            icon: Icons.restart_alt_rounded,
            onPressed: () async {
              final nav = Navigator.of(context);
              final ok = await showGhostDialog(
                context,
                title: 'Erase everything?',
                message: 'Your memories, saved places and settings will be deleted from this phone.',
                icon: Icons.restart_alt_rounded,
                confirmLabel: 'Erase',
                cancelLabel: 'Cancel',
                destructive: true,
              );
              if (ok == true) {
                nav.popUntil((r) => r.isFirst);
                await state.resetAll();
              }
            },
          ),
          const SizedBox(height: 26),
          const SectionLabel('Photo credits'),
          const SizedBox(height: 10),
          _Card(children: [
            for (var i = 0; i < places.length; i++) ...[
              if (i > 0) const Divider(height: 20, color: GC.line),
              Text(places[i].name, style: GC.body(14, color: GC.text, weight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 2),
              Text(places[i].credit, style: GC.body(12.5, color: GC.muted, height: 1.35)),
            ],
          ]),
          const SizedBox(height: 14),
          Text('Map data © OpenStreetMap contributors, map tiles © CARTO.', style: GC.body(12, color: GC.faint)),
          const SizedBox(height: 6),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: GC.amber, padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
            onPressed: () => showLicensePage(context: context, applicationName: 'Ghost City', applicationVersion: '1.0.0'),
            child: const Text('Open-source licences'),
          ),
          const SizedBox(height: 10),
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
