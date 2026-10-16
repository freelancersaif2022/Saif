import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../services/narrator.dart';
import '../widgets/common.dart';
import '../services/archive_api.dart';
import '../services/location.dart';
import '../services/places_store.dart';
import '../widgets/feedback.dart';
import '../widgets/location_gate.dart';
import 'paywall_screen.dart';

class WalksScreen extends StatefulWidget {
  const WalksScreen({super.key});

  @override
  State<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends State<WalksScreen> {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, pad.top + 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TIME WALKS', style: GC.label(color: GC.amber)),
              const SizedBox(height: 4),
              Text('Walks around you', style: GC.display(28)),
              const SizedBox(height: 8),
              Text('Routes through the landmarks near you, narrated stop by stop. Put on headphones and go.',
                  style: GC.body(15, color: GC.muted)),
            ],
          ),
        ),
        Expanded(
          child: LocationGate(
            builder: (context) => ListenableBuilder(listenable: _store, builder: (context, _) => _content(context)),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    final state = AppScope.of(context);
    final result = _store.result;
    if ((_store.status == LoadStatus.idle || _store.status == LoadStatus.loading) && result == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          for (var i = 0; i < 2; i++) ...[
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: GC.surface2,
                borderRadius: BorderRadius.circular(GC.radiusL + 2),
                border: Border.all(color: GC.line),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      );
    }
    if (_store.status == LoadStatus.error && result == null) {
      final e = _store.error!;
      return Center(
        child: e.failure == ApiFailure.offline
            ? StatePanel.offline(onAction: () => _store.load(force: true))
            : StatePanel(
                icon: Icons.cloud_off_rounded,
                title: 'Couldn’t plan walks',
                message: e.message,
                actionLabel: 'Try again',
                onAction: () => _store.load(force: true),
                color: GC.coral,
              ),
      );
    }
    final walks = buildWalks(result?.places ?? const [], _loc.name);
    if (walks.isEmpty) {
      return Center(
        child: StatePanel(
          icon: Icons.directions_walk_rounded,
          title: 'No walks here yet',
          message: 'A walk needs at least two landmarks within walking distance, and none are listed around this location.',
          actionLabel: 'Try again',
          onAction: () => _store.load(force: true),
        ),
      );
    }
    return RefreshIndicator(
      color: GC.amber,
      backgroundColor: GC.surface,
      onRefresh: () => _store.load(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          for (final w in walks) ...[
            _WalkCard(walk: w, locked: w.premium && !state.premium),
            const SizedBox(height: 16),
          ],
          Text('Stops and descriptions from Wikipedia. Distances are measured between stops in a straight line.',
              style: GC.body(12, color: GC.faint)),
        ],
      ),
    );
  }
}

/// Turns nearby landmarks into up to three walks. Each walk starts at the nearest
/// unused landmark and keeps adding the closest next stop within 1.5 km.
/// The first walk is free; the others are part of Plus.
List<Walk> buildWalks(List<NearbyPlace> places, String? areaName) {
  const dist = Distance();
  final pool = [...places]..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  final city = (areaName?.split(',').last.trim().isNotEmpty ?? false) ? areaName!.split(',').last.trim() : 'Near you';
  final walks = <Walk>[];
  while (pool.isNotEmpty && walks.length < 3) {
    final route = <NearbyPlace>[pool.removeAt(0)];
    while (route.length < 5) {
      NearbyPlace? best;
      var bestD = double.infinity;
      for (final p in pool) {
        final d = dist.as(LengthUnit.Meter, route.last.point, p.point);
        if (d < bestD) {
          bestD = d;
          best = p;
        }
      }
      if (best == null || bestD > 1500) break;
      route.add(best);
      pool.remove(best);
    }
    if (route.length < 2) continue;
    var meters = 0.0;
    final stops = <WalkStop>[];
    for (var i = 0; i < route.length; i++) {
      final p = route[i];
      if (i > 0) meters += dist.as(LengthUnit.Meter, route[i - 1].point, p.point);
      final note = i == 0 ? 'START' : '${meters < 1000 ? '${meters.round()} M' : '${(meters / 1000).toStringAsFixed(1)} KM'} FROM THE START';
      stops.add(WalkStop(
        name: p.title,
        point: p.point,
        note: note,
        narration: p.extract ?? p.description ?? p.title,
      ));
    }
    final km = meters / 1000;
    // About 4.5 km/h on foot plus a few minutes at each stop.
    final minutes = ((km / 4.5) * 60 + route.length * 5).round();
    final cover = route.firstWhere((p) => p.imageUrl != null, orElse: () => route.first).imageUrl ?? '';
    walks.add(Walk(
      id: 'near-${route.first.id}',
      title: '${route.first.title} to ${route.last.title}',
      city: city,
      cover: cover,
      minutes: minutes,
      distanceKm: km,
      premium: walks.isNotEmpty,
      intro: 'A ${route.length}-stop walk from ${route.first.title} to ${route.last.title}, with the story of each place read aloud.',
      stops: stops,
    ));
  }
  return walks;
}

class _WalkCard extends StatelessWidget {
  const _WalkCard({required this.walk, required this.locked});
  final Walk walk;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusL + 2), side: const BorderSide(color: GC.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: locked,
          builder: (_) => locked ? const PaywallScreen() : WalkScreen(walk: walk),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ArchivePhoto(walk.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0x00000000), Color(0xCC1A1815)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: locked
                        ? const PremiumBadge()
                        : const Pill(label: 'Free walk', background: Color(0xCC0F0E0C), foreground: GC.green),
                  ),
                  if (locked)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xCC0F0E0C),
                        child: Icon(Icons.lock_rounded, size: 17, color: GC.amberLight),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(walk.city.toUpperCase(), style: GC.label(color: GC.amber, size: 10.5)),
                  const SizedBox(height: 4),
                  Text(walk.title, style: GC.display(22, height: 1.15)),
                  const SizedBox(height: 8),
                  Text(walk.intro, style: GC.body(14, color: GC.muted, height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Meta(icon: Icons.schedule_rounded, text: '${walk.minutes} min'),
                      const SizedBox(width: 16),
                      _Meta(icon: Icons.straighten_rounded, text: '${walk.distanceKm.toStringAsFixed(1)} km'),
                      const SizedBox(width: 16),
                      _Meta(icon: Icons.place_outlined, text: '${walk.stops.length} stops'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: GC.faint),
      const SizedBox(width: 5),
      Text(text, style: GC.body(13, color: GC.textSoft, weight: FontWeight.w600, height: 1)),
    ]);
  }
}

/// A guided walk: route map on top, narrated stops below.
class WalkScreen extends StatefulWidget {
  const WalkScreen({super.key, required this.walk});
  final Walk walk;

  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen> {
  final _narrator = Narrator();
  final _map = MapController();
  int _current = 0;
  bool _started = false;

  Walk get walk => widget.walk;

  @override
  void initState() {
    super.initState();
    _narrator.addListener(() => setState(() {}));
    _narrator.onComplete = () {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narrator.rate = AppScope.read(context).speechRate;
  }

  @override
  void dispose() {
    _narrator.dispose();
    super.dispose();
  }

  Future<void> _goTo(int i, {bool speak = true}) async {
    await _narrator.stop();
    setState(() {
      _current = i;
      _started = true;
    });
    _map.move(walk.stops[i].point, 16);
    final s = walk.stops[i];
    _narrator.load('Stop ${i + 1}. ${s.name}. ${s.narration}');
    if (speak) await _narrator.play();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;
    final pts = walk.stops.map((s) => s.point).toList();
    final stop = walk.stops[_current];
    final last = _current == walk.stops.length - 1;

    return Scaffold(
      backgroundColor: GC.ground,
      body: Column(
        children: [
          SizedBox(
            height: h * 0.42,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCameraFit: CameraFit.coordinates(
                      coordinates: pts,
                      padding: EdgeInsets.fromLTRB(50, pad.top + 70, 50, 40),
                    ),
                    backgroundColor: const Color(0xFF14130F),
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.ghostcity.ghost_city',
                      retinaMode: RetinaMode.isHighDensity(context),
                    ),
                    PolylineLayer(polylines: [
                      Polyline(points: pts, color: GC.amber, strokeWidth: 4, pattern: StrokePattern.dashed(segments: const [10, 8])),
                    ]),
                    MarkerLayer(markers: [
                      for (var i = 0; i < pts.length; i++)
                        Marker(
                          point: pts[i],
                          width: 34,
                          height: 34,
                          child: GestureDetector(
                            onTap: () => _goTo(i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: i == _current && _started ? GC.amber : GC.surface2,
                                shape: BoxShape.circle,
                                border: Border.all(color: GC.amber, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text('${i + 1}',
                                  style: GC.body(13,
                                      color: i == _current && _started ? GC.onAmber : GC.text, weight: FontWeight.w800, height: 1)),
                            ),
                          ),
                        ),
                    ]),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 40,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [GC.ground.withValues(alpha: 0), GC.ground],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: pad.top + 10,
                  left: 16,
                  child: GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
                ),
                Positioned(
                  bottom: 6,
                  right: 12,
                  child: Text('© OpenStreetMap · © CARTO', style: GC.body(10, color: GC.faint, height: 1)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, pad.bottom + 24),
              children: [
                Text('${walk.city.toUpperCase()} · ${walk.minutes} MIN · ${walk.distanceKm.toStringAsFixed(1)} KM',
                    style: GC.label(color: GC.amber)),
                const SizedBox(height: 6),
                Text(walk.title, style: GC.display(28)),
                const SizedBox(height: 8),
                Text(walk.intro, style: GC.body(15, color: GC.muted)),
                const SizedBox(height: 20),
                if (_started)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GC.surface,
                      borderRadius: BorderRadius.circular(GC.radiusL),
                      border: Border.all(color: const Color(0x66E9B44C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NOW PLAYING · STOP ${_current + 1} OF ${walk.stops.length}', style: GC.label(color: GC.amber, size: 10.5)),
                        const SizedBox(height: 6),
                        Text(stop.name, style: GC.display(21)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: LinearProgressIndicator(
                            value: _narrator.progress,
                            minHeight: 5,
                            backgroundColor: GC.surface3,
                            color: GC.amber,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Previous stop',
                              onPressed: _current == 0 ? null : () => _goTo(_current - 1),
                              icon: const Icon(Icons.skip_previous_rounded),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryButton(
                                height: 50,
                                label: _narrator.isPlaying ? 'Pause' : 'Play',
                                icon: _narrator.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                onPressed: _narrator.toggle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton.filledTonal(
                              tooltip: 'Next stop',
                              onPressed: last ? null : () => _goTo(_current + 1),
                              icon: const Icon(Icons.skip_next_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  PrimaryButton(label: 'Start walk', icon: Icons.headphones_rounded, onPressed: () => _goTo(0)),
                const SizedBox(height: 26),
                const SectionLabel('Stops'),
                const SizedBox(height: 10),
                for (var i = 0; i < walk.stops.length; i++)
                  _StopRow(
                    index: i,
                    stop: walk.stops[i],
                    active: _started && i == _current,
                    done: _started && i < _current,
                    last: i == walk.stops.length - 1,
                    onTap: () => _goTo(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.index, required this.stop, required this.active, required this.done, required this.last, required this.onTap});
  final int index;
  final WalkStop stop;
  final bool active;
  final bool done;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 34,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: active ? GC.amber : (done ? GC.amberDeep : GC.surface2),
                      shape: BoxShape.circle,
                      border: Border.all(color: active || done ? GC.amber : GC.lineStrong),
                    ),
                    alignment: Alignment.center,
                    child: done
                        ? const Icon(Icons.check_rounded, size: 16, color: GC.amber)
                        : Text('${index + 1}', style: GC.body(12.5, color: active ? GC.onAmber : GC.text, weight: FontWeight.w800, height: 1)),
                  ),
                  if (!last) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: GC.line)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stop.note ?? (stop.year == null ? 'STOP ${index + 1}' : '${stop.year}'), style: GC.label(color: GC.amber, size: 10.5)),
                    const SizedBox(height: 3),
                    Text(stop.name, style: GC.display(18, height: 1.2)),
                    const SizedBox(height: 5),
                    Text(stop.narration, style: GC.body(14, color: GC.muted, height: 1.45), maxLines: active ? 10 : 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
