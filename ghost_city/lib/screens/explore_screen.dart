import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../services/archive_api.dart';
import '../services/location.dart';
import '../services/places_store.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import '../widgets/location_gate.dart';
import 'nearby_place_screen.dart';
import 'paywall_screen.dart';
import 'settings_screen.dart';

/// Notable places around the user's location, from Wikipedia.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _savedOnly = false;
  final _store = PlacesStore.instance;
  final _loc = LocationService.instance;

  @override
  void initState() {
    super.initState();
    _loc.ensureStarted();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, pad.top + 14, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EXPLORE', style: GC.label(color: GC.amber)),
                    const SizedBox(height: 4),
                    Text('Places around you', style: GC.display(28)),
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
        Expanded(
          child: _savedOnly
              ? _content(context)
              : LocationGate(builder: (context) => ListenableBuilder(listenable: _store, builder: (context, _) => _content(context))),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    final state = AppScope.of(context);
    final status = _store.status;
    final result = _store.result;
    final all = result?.places ?? const <NearbyPlace>[];
    final here = _loc.point;
    final saved = [for (final p in state.savedPlaces) here == null ? p : p.withDistanceFrom(here)]
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    final list = _savedOnly ? saved : all;
    final featured = !_savedOnly && all.isNotEmpty ? all.first : null;

    Widget chips() => Row(
          children: [
            ChoiceChipX(label: 'All places', selected: !_savedOnly, solid: true, onTap: () => setState(() => _savedOnly = false)),
            const SizedBox(width: 8),
            ChoiceChipX(label: 'Saved (${saved.length})', selected: _savedOnly, solid: true, onTap: () => setState(() => _savedOnly = true)),
          ],
        );

    if (!_savedOnly && (status == LoadStatus.idle || status == LoadStatus.loading) && result == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          const _Skeleton(height: 380),
          const SizedBox(height: 24),
          chips(),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++) ...[const _Skeleton(height: 116), const SizedBox(height: 12)],
        ],
      );
    }
    if (!_savedOnly && status == LoadStatus.error && result == null) {
      final e = _store.error!;
      return Center(
        child: e.failure == ApiFailure.offline
            ? StatePanel.offline(onAction: () => _store.load(force: true))
            : StatePanel(
                icon: Icons.cloud_off_rounded,
                title: 'Couldn’t load places',
                message: e.message,
                actionLabel: 'Try again',
                onAction: () => _store.load(force: true),
                color: GC.coral,
              ),
      );
    }

    final scopeNote = switch (result?.scope) {
      NearbyScope.near => 'Nothing listed right where you are, so these are the nearest places.',
      NearbyScope.region => 'Nothing listed close by, so these are places in your wider area.',
      _ => null,
    };

    return RefreshIndicator(
      color: GC.amber,
      backgroundColor: GC.surface,
      onRefresh: () => _store.load(force: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (!_savedOnly && _loc.name != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(children: [
                  const Icon(Icons.near_me_rounded, size: 14, color: GC.amber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_loc.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: GC.body(13.5, color: GC.muted)),
                  ),
                ]),
              ),
            ),
          if (featured != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(child: _FeaturedCard(place: featured)),
            ),
          if (scopeNote != null && !_savedOnly)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: GC.faint),
                  const SizedBox(width: 8),
                  Expanded(child: Text(scopeNote, style: GC.body(13, color: GC.muted, height: 1.4))),
                ]),
              ),
            ),
          if (!state.premium && !_savedOnly && all.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(child: _PlusBanner()),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(child: chips()),
          ),
          if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Center(
                  child: _savedOnly
                      ? const StatePanel(
                          icon: Icons.bookmark_border_rounded,
                          title: 'No saved places yet',
                          message: 'Tap the bookmark on any place to keep it here.',
                        )
                      : StatePanel(
                          icon: Icons.travel_explore_rounded,
                          title: 'No places found',
                          message: 'There are no listed landmarks around this location yet. Try again somewhere else.',
                          actionLabel: 'Try again',
                          onAction: () => _store.load(force: true),
                        ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _PlaceRow(place: list[i], saved: state.isPlaceSaved(list[i].id)),
              ),
            ),
        ],
      ),
    );
  }
}

String distanceLabel(double m) => m < 1000 ? '${m.round()} m away' : '${(m / 1000).toStringAsFixed(m < 10000 ? 1 : 0)} km away';

/// A photo from the web, or a warm placeholder when a place has none.
class PlaceImage extends StatelessWidget {
  const PlaceImage(this.url, {super.key, this.alignment = Alignment.center});
  final String? url;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A2F1A), Color(0xFF1A1815)],
        ),
      ),
      child: const Center(child: Icon(Icons.account_balance_outlined, color: Color(0x80E9B44C), size: 34)),
    );
    if (url == null) return placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      alignment: alignment,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) => progress == null ? child : const ColoredBox(color: GC.surface2),
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: GC.surface2,
        borderRadius: BorderRadius.circular(GC.radiusL),
        border: Border.all(color: GC.line),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.place});
  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NearbyPlaceScreen(place: place))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GC.radiusL + 2),
        child: AspectRatio(
          aspectRatio: 4 / 4.4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(tag: 'np-${place.id}', child: PlaceImage(place.imageUrl, alignment: const Alignment(0, -0.3))),
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
              Positioned(
                top: 16,
                left: 16,
                child: Pill(label: 'Featured · ${distanceLabel(place.distanceMeters)}', background: const Color(0xCC0F0E0C)),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.title, style: GC.display(32), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (place.description != null) ...[
                      const SizedBox(height: 6),
                      Text(_cap(place.description!), style: GC.body(14.5, color: GC.textSoft, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
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

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class _PlusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.amberDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusL), side: const BorderSide(color: Color(0x66E9B44C))),
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
                child: Text('Unlock every walk, Ghost mode and unlimited memories.',
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
  final NearbyPlace place;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusL), side: const BorderSide(color: GC.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NearbyPlaceScreen(place: place))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'np-${place.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(width: 92, height: 92, child: PlaceImage(place.imageUrl)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(distanceLabel(place.distanceMeters).toUpperCase(), style: GC.label(color: GC.amber, size: 10.5)),
                    const SizedBox(height: 5),
                    Text(place.title, style: GC.display(18, height: 1.15), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (place.description != null) ...[
                      const SizedBox(height: 5),
                      Text(_cap(place.description!), maxLines: 1, overflow: TextOverflow.ellipsis, style: GC.body(13, color: GC.muted, height: 1.2)),
                    ],
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
