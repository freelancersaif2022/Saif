import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';

class _Plan {
  const _Plan(this.id, this.name, this.price, this.period, this.note);
  final String id;
  final String name;
  final String price;
  final String period;
  final String? note;
}

// Display prices. Replace with your store prices when you connect in-app purchases.
const _plans = [
  _Plan('year', 'Yearly', '\$29.99', '/ year', 'Best value'),
  _Plan('month', 'Monthly', '\$3.99', '/ month', null),
  _Plan('life', 'Lifetime', '\$59.99', 'once', null),
];

const _benefits = [
  (Icons.auto_stories_rounded, 'Every story', 'Unlock all narrated stories at every place.'),
  (Icons.directions_walk_rounded, 'Guided Time Walks', 'Narrated routes, stop by stop, with the route on a map.'),
  (Icons.layers_rounded, 'Ghost mode', 'Fade the past over the present with a single slider.'),
  (Icons.mic_rounded, 'Unlimited memories', 'Record as many voice memories as you like.'),
];

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, this.reason});
  final String? reason;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _plan = 'year';
  bool _busy = false;

  Future<void> _unlock() async {
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    await AppScope.read(context).setPremium(true);
    if (!mounted) return;
    setState(() => _busy = false);
    await showGhostDialog(
      context,
      title: 'Welcome to Plus',
      message: 'Every story, walk and lens mode is now open. Enjoy the trip back in time.',
      icon: Icons.auto_awesome,
      confirmLabel: 'Start exploring',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;
    final premium = AppScope.of(context).premium;

    return Scaffold(
      backgroundColor: GC.ground,
      body: Stack(
        children: [
          SizedBox(
            height: h * 0.4,
            width: double.infinity,
            child: const Stack(fit: StackFit.expand, children: [
              ArchivePhoto('assets/photos/saratoga_1905.jpg'),
              BottomFade(stops: [0.25, 0.92]),
            ]),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(22, h * 0.27, 22, pad.bottom + 24),
            children: [
              const Align(alignment: Alignment.centerLeft, child: PremiumBadge()),
              const SizedBox(height: 14),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'See the whole city\n'),
                  TextSpan(text: 'as it was.', style: GC.display(36, color: GC.amber, style: FontStyle.italic)),
                ]),
                style: GC.display(36, height: 1.08),
              ),
              if (widget.reason != null) ...[
                const SizedBox(height: 10),
                Text(widget.reason!, style: GC.body(15, color: GC.amberLight)),
              ],
              const SizedBox(height: 22),
              for (final b in _benefits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: GC.amberDeep, borderRadius: BorderRadius.circular(12)),
                        child: Icon(b.$1, color: GC.amber, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.$2, style: GC.body(15.5, color: GC.text, weight: FontWeight.w700, height: 1.3)),
                            const SizedBox(height: 2),
                            Text(b.$3, style: GC.body(13.5, color: GC.muted, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              if (premium)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: GC.amberDeep,
                    borderRadius: BorderRadius.circular(GC.radiusL),
                    border: Border.all(color: GC.amber),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: GC.amber),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Plus is active on this phone.', style: GC.body(15, color: GC.amberLight, weight: FontWeight.w700))),
                  ]),
                )
              else ...[
                for (final p in _plans)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlanTile(plan: p, selected: _plan == p.id, onTap: () => setState(() => _plan = p.id)),
                  ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: _busy ? 'Unlocking…' : 'Unlock Ghost City Plus',
                  icon: _busy ? null : Icons.lock_open_rounded,
                  onPressed: _busy ? null : _unlock,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text('Test mode: no payment is taken. Cancel anytime.',
                      textAlign: TextAlign.center, style: GC.body(12, color: GC.faint)),
                ),
              ],
            ],
          ),
          Positioned(
            top: pad.top + 10,
            right: 16,
            child: GlassIconButton(icon: Icons.close_rounded, tooltip: 'Close', onPressed: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.selected, required this.onTap});
  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? GC.amberDeep : GC.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GC.radiusM + 2),
        side: BorderSide(color: selected ? GC.amber : GC.line, width: selected ? 1.6 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: selected ? GC.amber : GC.faint, size: 22),
              const SizedBox(width: 12),
              Text(plan.name, style: GC.body(16, color: GC.text, weight: FontWeight.w700, height: 1.2)),
              if (plan.note != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: GC.amber, borderRadius: BorderRadius.circular(99)),
                  child: Text(plan.note!.toUpperCase(), style: GC.label(color: GC.onAmber, size: 9.5)),
                ),
              ],
              const Spacer(),
              Text(plan.price, style: GC.body(16, color: GC.text, weight: FontWeight.w800, height: 1.2)),
              const SizedBox(width: 4),
              Text(plan.period, style: GC.body(12.5, color: GC.muted, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}
