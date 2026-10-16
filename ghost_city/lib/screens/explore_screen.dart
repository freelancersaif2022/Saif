import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../widgets/common.dart';
import 'paywall_screen.dart';
import 'place_screen.dart';
import 'settings_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _savedOnly = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pad = MediaQuery.paddingOf(context);
    final list = _savedOnly ? places.where((p) => state.isSaved(p.id)).toList() : places;
    final featured = places.first;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, pad.top + 14, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXPLORE', style: GC.label(color: GC.amber)),
                      const SizedBox(height: 4),
                      Text('Places that remember', style: GC.display(28)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  icon: const Icon(Icons.settings_outlined, color: GC.text),
                ),
              ],
            ),
          ),
        ),
        if (!_savedOnly)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(child: _FeaturedCard(place: featured)),
          ),
        if (!state.premium && !_savedOnly)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(child: _PlusBanner()),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                ChoiceChipX(label: 'All places', selected: !_savedOnly, solid: true, onTap: () => setState(() => _savedOnly = false)),
                const SizedBox(width: 8),
                ChoiceChipX(
                  label: 'Saved (${state.saved.length})',
                  selected: _savedOnly,
                  solid: true,
                  onTap: () => setState(() => _savedOnly = true),
                ),
              ],
            ),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                children: [
                  const Icon(Icons.bookmark_border_rounded, color: GC.faint, size: 36),
                  const SizedBox(height: 12),
                  Text('No saved places yet', style: GC.display(20)),
                  const SizedBox(height: 6),
                  Text('Tap the bookmark on any place to keep it here.',
                      textAlign: TextAlign.center, style: GC.body(14, color: GC.muted)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PlaceRow(place: list[i], saved: state.isSaved(list[i].id)),
            ),
          ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceScreen(place: place))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GC.radiusL + 2),
        child: AspectRatio(
          aspectRatio: 4 / 4.4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArchivePhoto(place.image, alignment: const Alignment(0, -0.3)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x00000000), Color(0xF20F0E0C)],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              Positioned(top: 16, left: 16, child: Pill(label: 'Featured · ${place.dateLabel}', background: const Color(0xCC0F0E0C))),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: GC.display(32)),
                    const SizedBox(height: 6),
                    Text(place.tagline, style: GC.body(14.5, color: GC.textSoft, height: 1.4)),
                    const SizedBox(height: 10),
                    Text(place.location.toUpperCase(), style: GC.label(color: GC.amber)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.amberDeep,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GC.radiusL), side: const BorderSide(color: Color(0x66E9B44C))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const PremiumBadge(),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Unlock every story, guided walks and Ghost mode.',
                    style: GC.body(14, color: GC.amberLight, weight: FontWeight.w600, height: 1.35)),
              ),
              const Icon(Icons.chevron_right_rounded, color: GC.amber),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.place, required this.saved});
  final Place place;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusL), side: const BorderSide(color: GC.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceScreen(place: place))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'photo-${place.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(width: 92, height: 92, child: ArchivePhoto(place.image)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.dateLabel.toUpperCase(), style: GC.label(color: GC.amber, size: 10.5)),
                    const SizedBox(height: 5),
                    Text(place.name, style: GC.display(18, height: 1.15), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Text(place.location, style: GC.body(13, color: GC.muted, height: 1.2)),
                  ],
                ),
              ),
              if (saved) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.bookmark_rounded, color: GC.amber, size: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
