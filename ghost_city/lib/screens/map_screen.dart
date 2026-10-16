import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app/theme.dart';
import '../data/content.dart';
import '../widgets/common.dart';
import 'lens_screen.dart';
import 'place_screen.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final _map = MapController();
  final _cards = PageController(viewportFraction: 0.9);
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  AnimationController? _fly;
  int _era = 0;
  int _selected = 0;
  bool _ready = false;
  double _zoom = 2.6;
  bool _cardsMoving = false;

  List<Place> get _visible => places.where((p) => eras[_era].contains(p.year)).toList();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fly?.dispose();
    _cards.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Smooth "fly to" that zooms out on long jumps, like a real globe app.
  void _flyTo(LatLng target, double zoom) {
    if (!_ready) return;
    _fly?.dispose();
    final cam = _map.camera;
    final from = cam.center;
    final z0 = cam.zoom;
    final km = const Distance().as(LengthUnit.Kilometer, from, target);
    final dip = km > 1000 ? 5.5 : (km > 150 ? 3.0 : 0.0);
    final c = AnimationController(vsync: this, duration: Duration(milliseconds: km > 1000 ? 1700 : 900));
    final curve = CurvedAnimation(parent: c, curve: Curves.easeInOutCubic);
    c.addListener(() {
      final t = curve.value;
      final lat = from.latitude + (target.latitude - from.latitude) * t;
      final lng = from.longitude + (target.longitude - from.longitude) * t;
      final z = (z0 + (zoom - z0) * t - dip * math.sin(math.pi * t)).clamp(2.0, 18.0);
      _map.move(LatLng(lat, lng), z);
    });
    _fly = c..forward();
  }

  void _select(int i, {bool fromCards = false}) {
    final list = _visible;
    if (list.isEmpty) return;
    setState(() => _selected = i.clamp(0, list.length - 1));
    _flyTo(list[_selected].point, 15.5);
    if (!fromCards && _cards.hasClients) {
      _cardsMoving = true;
      _cards
          .animateToPage(_selected, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic)
          .whenComplete(() => _cardsMoving = false);
    }
  }

  void _showAll() {
    final pts = _visible.map((p) => p.point).toList();
    if (pts.isEmpty || !_ready) return;
    if (pts.length == 1) return _flyTo(pts.first, 14);
    _fly?.stop();
    _map.fitCamera(CameraFit.coordinates(
      coordinates: pts,
      padding: const EdgeInsets.fromLTRB(60, 200, 60, 260),
      maxZoom: 15,
    ));
  }

  void _setEra(int e) {
    setState(() {
      _era = e;
      _selected = 0;
    });
    if (_cards.hasClients) _cards.jumpToPage(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAll());
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    final pad = MediaQuery.paddingOf(context);
    final query = _search.text.trim().toLowerCase();
    final results = query.isEmpty
        ? const <Place>[]
        : places
            .where((p) => '${p.name} ${p.city} ${p.country} ${p.year}'.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      backgroundColor: GC.ground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: const LatLng(44, -40),
              initialZoom: 2.6,
              minZoom: 2,
              maxZoom: 18,
              backgroundColor: const Color(0xFF14130F),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              onMapReady: () {
                _ready = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => _showAll());
              },
              onTap: (_, _) => _searchFocus.unfocus(),
              onPositionChanged: (camera, _) {
                final z = camera.zoom;
                if ((z < 6) != (_zoom < 6)) {
                  setState(() => _zoom = z);
                } else {
                  _zoom = z;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.ghostcity.ghost_city',
                retinaMode: RetinaMode.isHighDensity(context),
                maxZoom: 19,
              ),
              // Warm the dark basemap toward the app's sepia palette.
              const IgnorePointer(child: ColoredBox(color: Color(0x0FE9B44C), child: SizedBox.expand())),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < list.length; i++)
                    Marker(
                      point: list[i].point,
                      width: 130,
                      height: 58,
                      alignment: Alignment.topCenter,
                      child: _YearPin(
                        place: list[i],
                        selected: i == _selected,
                        compact: _zoom < 6 && i != _selected,
                        onTap: () => _select(i),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Top: search and era filters.
          Positioned(
            top: pad.top + 10,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xF2201D17),
                          borderRadius: BorderRadius.circular(GC.radiusM),
                          border: Border.all(color: GC.line),
                          boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 30, offset: Offset(0, 10))],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: GC.muted, size: 21),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _search,
                                focusNode: _searchFocus,
                                style: GC.body(15, color: GC.text, height: 1.2),
                                cursorColor: GC.amber,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: 'Search a place, city or year',
                                  hintStyle: GC.body(15, color: GC.faint, height: 1.2),
                                ),
                              ),
                            ),
                            if (_search.text.isNotEmpty)
                              IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _search.clear();
                                  _searchFocus.unfocus();
                                },
                                icon: const Icon(Icons.close_rounded, size: 20, color: GC.muted),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: const Color(0xF2201D17),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GC.radiusM), side: const BorderSide(color: GC.line)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(Icons.tune_rounded, color: GC.text, size: 22, semanticLabel: 'Settings'),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_searchFocus.hasFocus && query.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: GC.surface,
                      borderRadius: BorderRadius.circular(GC.radiusM),
                      border: Border.all(color: GC.line),
                    ),
                    child: results.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text('No places match “${_search.text}” yet.', style: GC.body(14, color: GC.muted)),
                          )
                        : Column(
                            children: [
                              for (final p in results)
                                ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(width: 44, height: 44, child: ArchivePhoto(p.image)),
                                  ),
                                  title: Text(p.name, style: GC.body(15, color: GC.text, weight: FontWeight.w600, height: 1.2)),
                                  subtitle: Text('${p.city} · ${p.dateLabel}', style: GC.body(13, color: GC.muted, height: 1.3)),
                                  onTap: () {
                                    _searchFocus.unfocus();
                                    _search.clear();
                                    if (_era != 0) _setEra(0);
                                    final i = _visible.indexOf(p);
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _select(i));
                                  },
                                ),
                            ],
                          ),
                  )
                else ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: eras.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ChoiceChipX(label: eras[i].label, selected: i == _era, onTap: () => _setEra(i)),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Map data attribution (required by OpenStreetMap and CARTO).
          Positioned(
            left: 18,
            bottom: 206,
            child: IgnorePointer(
              child: Text('© OpenStreetMap contributors · © CARTO', style: GC.body(10, color: GC.faint, height: 1)),
            ),
          ),

          // Right: show all control.
          Positioned(
            right: 16,
            bottom: 210,
            child: Material(
              color: const Color(0xF2201D17),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: GC.line)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _showAll,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.public_rounded, color: GC.amber, size: 22, semanticLabel: 'Show all places'),
                ),
              ),
            ),
          ),

          // Bottom: swipeable place cards.
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            height: 182,
            child: list.isEmpty
                ? Center(child: Text('No places from this era yet.', style: GC.body(14, color: GC.muted)))
                : PageView.builder(
                    controller: _cards,
                    itemCount: list.length,
                    onPageChanged: (i) {
                      if (_cardsMoving || i == _selected) return;
                      HapticFeedback.selectionClick();
                      _select(i, fromCards: true);
                    },
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _PlaceCard(place: list[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _YearPin extends StatelessWidget {
  const _YearPin({required this.place, required this.selected, required this.compact, required this.onTap});
  final Place place;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      // Zoomed out: a small dot keeps nearby places from piling up.
      return GestureDetector(
        onTap: onTap,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF2A251C),
              shape: BoxShape.circle,
              border: Border.all(color: GC.amber, width: 2.5),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
            decoration: BoxDecoration(
              color: selected ? GC.amber : const Color(0xFF2A251C),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: selected ? GC.amber : const Color(0x80E9B44C)),
              boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(child: SizedBox(width: 24, height: 24, child: ArchivePhoto(place.image))),
                const SizedBox(width: 6),
                Text('${place.year}',
                    style: GC.body(12.5, color: selected ? GC.onAmber : GC.text, weight: FontWeight.w800, height: 1)),
              ],
            ),
          ),
          Container(width: 2, height: 12, color: selected ? GC.amber : const Color(0x99E9B44C)),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: selected ? GC.amber : const Color(0xFFB3A893),
              shape: BoxShape.circle,
              boxShadow: selected ? const [BoxShadow(color: Color(0x66E9B44C), blurRadius: 10, spreadRadius: 4)] : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GC.surface,
        borderRadius: BorderRadius.circular(GC.radiusL),
        border: Border.all(color: GC.line),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 30, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceScreen(place: place))),
            child: Row(
              children: [
                Hero(
                  tag: 'photo-${place.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(width: 78, height: 78, child: ArchivePhoto(place.image)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${place.dateLabel.toUpperCase()} · ${place.yearsAgo} YEARS AGO',
                          style: GC.label(color: GC.amber, size: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(place.name, style: GC.display(19, height: 1.15), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('${place.location} · ${place.stories.length} stories',
                          style: GC.body(13, color: GC.muted, height: 1.3), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: GC.faint),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Open Time Lens',
            icon: Icons.center_focus_strong_rounded,
            height: 48,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LensScreen(place: place))),
          ),
        ],
      ),
    );
  }
}
