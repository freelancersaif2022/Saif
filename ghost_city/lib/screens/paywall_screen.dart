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
    await AppScope.read(context).activatePlan(_plan);
    if (!mounted) return;
    setState(() => _busy = false);
    await showGhostDialog(
      context,
      title: 'Welcome to Plus',
      message: 'Every story, walk and lens mode is now open. Enjoy the trip back in time.',
      icon: Icons.workspace_premium_rounded,
      confirmLabel: 'Start exploring',
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _cancel() async {
    final state = AppScope.read(context);
    final lifetime = state.plan == 'life';
    final ok = await showGhostDialog(
      context,
      title: lifetime ? 'Remove lifetime Plus?' : 'Cancel your plan?',
      message: 'Plus features will lock again on this phone. Your memories and saved places stay.',
      icon: Icons.workspace_premium_rounded,
      confirmLabel: lifetime ? 'Remove Plus' : 'Cancel plan',
      cancelLabel: 'Keep Plus',
      destructive: true,
    );
    if (ok != true || !mounted) return;
    await state.cancelPlan();
    showToast('Plan cancelled', kind: ToastKind.info, message: 'You are back on the free plan.');
  }

  static String _date(DateTime d) =>
      '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;
    final state = AppScope.of(context);
    final premium = state.premium;
    final active = _plans.firstWhere((p) => p.id == (state.plan ?? 'year'));

    final benefits = [
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
              if (premium) const Icon(Icons.check_circle_rounded, color: GC.amber, size: 20),
            ],
          ),
        ),
    ];

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
              if (premium)
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Your Plus\n'),
                    TextSpan(text: 'membership.', style: GC.display(36, color: GC.amber, style: FontStyle.italic)),
                  ]),
                  style: GC.display(36, height: 1.08),
                )
              else
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'See the whole city\n'),
                    TextSpan(text: 'as it was.', style: GC.display(36, color: GC.amber, style: FontStyle.italic)),
                  ]),
                  style: GC.display(36, height: 1.08),
                ),
              if (widget.reason != null && !premium) ...[
                const SizedBox(height: 10),
                Text(widget.reason!, style: GC.body(15, color: GC.amberLight)),
              ],
              const SizedBox(height: 22),
              if (premium) ...[
                // Active plan.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3A2F1A), Color(0xFF221C12)],
                    ),
                    borderRadius: BorderRadius.circular(GC.radiusL),
                    border: Border.all(color: GC.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${active.name} plan', style: GC.display(22, height: 1.1)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: GC.green.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(99)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(width: 7, height: 7, decoration: const BoxDecoration(color: GC.green, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('ACTIVE', style: GC.label(color: GC.green, size: 10.5)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${active.price} ${active.period}', style: GC.body(15, color: GC.amberLight, weight: FontWeight.w700)),
                      const Divider(height: 26, color: GC.line),
                      _InfoRow(label: 'Started', value: state.planSince == null ? '—' : _date(state.planSince!)),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: state.plan == 'life' ? 'Access' : 'Renews on',
                        value: state.plan == 'life' ? 'Lifetime, never expires' : (state.renewsOn == null ? '—' : _date(state.renewsOn!)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel('Included'),
                const SizedBox(height: 12),
                ...benefits,
              ] else ...[
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
                const SizedBox(height: 26),
                ...benefits,
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: GC.surface, borderRadius: BorderRadius.circular(GC.radiusM), border: Border.all(color: GC.line)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.event_repeat_rounded, color: GC.muted, size: 19),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Monthly and yearly plans renew automatically until you cancel. You can cancel anytime from '
                        'Settings › Manage Plus. Lifetime is a single payment with no renewal.',
                        style: GC.body(13, color: GC.muted, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              if (premium) ...[
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GC.coral,
                      side: BorderSide(color: GC.coral.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM)),
                      textStyle: GC.body(15, weight: FontWeight.w700, height: 1),
                    ),
                    child: Text(state.plan == 'life' ? 'Remove lifetime Plus' : 'Cancel plan'),
                  ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GC.body(14, color: GC.muted, height: 1.2)),
        const Spacer(),
        Text(value, style: GC.body(14, color: GC.text, weight: FontWeight.w700, height: 1.2)),
      ],
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
