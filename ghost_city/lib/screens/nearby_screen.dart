import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../app/theme.dart';
import '../services/archive_api.dart';
import '../services/connectivity.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'photo_viewer_screen.dart';
import 'place_search_sheet.dart';
import 'satellite_screen.dart';

enum _Tab { street, photos, satellite }

enum _Status { idle, loading, done, error }

class _Load<T> {
  _Status status = _Status.idle;
  T? data;
  ApiException? error;
}

class _AgeRange {
  const _AgeRange(this.label, this.min, this.max);
  final String label;
  final int min;
  final int max;
}

const _ages = [
  _AgeRange('All', 5, 25),
  _AgeRange('5–10 yrs', 5, 10),
  _AgeRange('10–15 yrs', 10, 15),
  _AgeRange('15–20 yrs', 15, 20),
];

/// "Near me": street photos, archive photos and satellite images of the place
/// you are standing in, from 5 to 20+ years ago.
class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key, this.initialPoint, this.initialName});

  /// When set, shows that spot instead of the phone's location (opened from the map).
  final LatLng? initialPoint;
  final String? initialName;

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> with AutomaticKeepAliveClientMixin {
  final _api = ArchiveApi();
  final _net = ConnectivityService.instance;

  LatLng? _point;
  String? _name;
  bool _fromGps = false;

  bool _locating = false;
  String? _locationProblem; // 'off' | 'denied' | 'forever' | 'failed'

  _Tab _tab = _Tab.street;
  int _age = 0;

  final _street = _Load<List<PastPhoto>>();
  final _photos = _Load<List<PastPhoto>>();
  final _sat = _Load<List<Release>>();
  int _generation = 0;

  bool get _standalone => widget.initialPoint != null;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _net.addListener(_onNetwork);
    if (widget.initialPoint != null) {
      _setPoint(widget.initialPoint!, name: widget.initialName, gps: false);
    } else {
      _locate();
    }
  }

  @override
  void dispose() {
    _net.removeListener(_onNetwork);
    super.dispose();
  }

  void _onNetwork() {
    if (!mounted) return;
    setState(() {});
    // Coming back online: load whatever is missing.
    if (_net.online && _point != null) {
      if (_name == null) _loadName();
      _loadCurrentTab();
    }
  }

  // ------------------------------------------------------------- location

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locationProblem = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _locationProblem = 'off');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        setState(() => _locationProblem = 'forever');
        return;
      }
      if (perm == LocationPermission.denied) {
        setState(() => _locationProblem = 'denied');
        return;
      }
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && _point == null) _setPoint(LatLng(last.latitude, last.longitude), gps: true);
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      final p = LatLng(pos.latitude, pos.longitude);
      if (_point == null || const Distance().as(LengthUnit.Meter, _point!, p) > 60) _setPoint(p, gps: true);
    } on TimeoutException {
      if (_point == null) setState(() => _locationProblem = 'failed');
    } catch (_) {
      if (_point == null) setState(() => _locationProblem = 'failed');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _setPoint(LatLng p, {String? name, required bool gps}) {
    _generation++;
    setState(() {
      _point = p;
      _name = name;
      _fromGps = gps;
      _locationProblem = null;
      for (final l in [_street, _photos]) {
        l
          ..status = _Status.idle
          ..data = null
          ..error = null;
      }
    });
    if (name == null) _loadName();
    _loadCurrentTab();
  }

  Future<void> _loadName() async {
    final p = _point;
    if (p == null || !_net.online) return;
    final gen = _generation;
    try {
      final n = await _api.placeName(p);
      if (mounted && gen == _generation && n != null) setState(() => _name = n);
    } catch (_) {}
  }

  Future<void> _search() async {
    final result = await showPlaceSearch(context, _api);
    if (result != null) _setPoint(result.point, name: result.name, gps: false);
  }

  // ------------------------------------------------------------- data

  void _loadCurrentTab({bool force = false}) {
    switch (_tab) {
      case _Tab.street:
        _loadPhotos(_street, force: force);
      case _Tab.photos:
        _loadPhotos(_photos, force: force);
      case _Tab.satellite:
        _loadSatellite(force: force);
    }
  }

  Future<void> _loadPhotos(_Load<List<PastPhoto>> load, {bool force = false}) async {
    final p = _point;
    if (p == null) return;
    if (!force && (load.status == _Status.loading || load.status == _Status.done)) return;
    if (!_net.online) {
      showToast('No internet connection', kind: ToastKind.offline, message: 'Connect to load photos of this place.');
      return;
    }
    final gen = _generation;
    setState(() {
      load.status = _Status.loading;
      load.error = null;
    });
    try {
      final data = identical(load, _street) ? await _api.mapillary(p, minYearsAgo: 5) : await _api.wikimedia(p, minYearsAgo: 5);
      if (!mounted || gen != _generation) return;
      setState(() {
        load
          ..data = data
          ..status = _Status.done;
      });
    } on ApiException catch (e) {
      if (!mounted || gen != _generation) return;
      setState(() {
        load
          ..error = e
          ..status = _Status.error;
      });
      if (e.failure == ApiFailure.offline) _net.refresh();
    }
  }

  Future<void> _loadSatellite({bool force = false}) async {
    if (!force && (_sat.status == _Status.loading || _sat.status == _Status.done)) return;
    if (!_net.online) {
      showToast('No internet connection', kind: ToastKind.offline, message: 'Satellite images need a connection.');
      return;
    }
    setState(() => _sat.status = _Status.loading);
    try {
      final r = await _api.waybackReleases();
      if (!mounted) return;
      setState(() {
        _sat
          ..data = r
          ..status = _Status.done;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _sat
          ..error = e
          ..status = _Status.error;
      });
    }
  }

  void _selectTab(_Tab t) {
    HapticFeedback.selectionClick();
    setState(() => _tab = t);
    _loadCurrentTab();
  }

  Future<void> _refresh() async {
    if (!await _net.refresh()) {
      showToast('No internet connection', kind: ToastKind.offline, message: 'Check Wi-Fi or mobile data and try again.');
      return;
    }
    if (_point == null) {
      await _locate();
      return;
    }
    if (_name == null) _loadName();
    _loadCurrentTab(force: true);
  }

  // ------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: GC.ground,
      body: RefreshIndicator(
        color: GC.amber,
        backgroundColor: GC.surface,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, 0),
              sliver: SliverToBoxAdapter(child: _header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(child: _tabs()),
            ),
            if (_tab != _Tab.satellite && _point != null && _net.online)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 20),
                      itemCount: _ages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ChoiceChipX(
                        label: _ages[i].label,
                        selected: i == _age,
                        solid: true,
                        onTap: () => setState(() => _age = i),
                      ),
                    ),
                  ),
                ),
              ),
            ..._body(),
            SliverToBoxAdapter(child: SizedBox(height: pad.bottom + 30)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final p = _point;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_standalone) ...[
          GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(_fromGps || p == null ? Icons.near_me_rounded : Icons.place_rounded, size: 14, color: GC.amber),
                const SizedBox(width: 6),
                Text(p == null ? 'NEAR ME' : (_fromGps ? 'YOU ARE HERE' : 'THIS SPOT'), style: GC.label(color: GC.amber)),
              ]),
              const SizedBox(height: 6),
              Text(
                _name ?? (p == null ? (_locating ? 'Finding you…' : 'Where are you?') : 'Unnamed street'),
                style: GC.display(27, height: 1.12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (p != null) ...[
                const SizedBox(height: 4),
                Text('${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}',
                    style: GC.body(12.5, color: GC.faint, height: 1.2)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        _RoundAction(icon: Icons.search_rounded, tooltip: 'Search a place', onTap: _search),
        const SizedBox(width: 8),
        _RoundAction(
          icon: Icons.my_location_rounded,
          tooltip: 'Use my location',
          busy: _locating,
          onTap: _locating ? null : _locate,
        ),
      ],
    );
  }

  Widget _tabs() {
    Widget seg(_Tab t, IconData icon, String label) {
      final on = t == _tab;
      return Expanded(
        child: GestureDetector(
          onTap: () => _selectTab(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(color: on ? GC.amber : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: on ? GC.onAmber : GC.muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: GC.body(13.5, color: on ? GC.onAmber : GC.textSoft, weight: FontWeight.w700, height: 1)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: GC.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GC.line)),
      child: Row(children: [
        seg(_Tab.street, Icons.streetview_rounded, 'Street'),
        seg(_Tab.photos, Icons.photo_library_outlined, 'Photos'),
        seg(_Tab.satellite, Icons.satellite_alt_rounded, 'Satellite'),
      ]),
    );
  }

  List<Widget> _body() {
    Widget fill(Widget child) => SliverFillRemaining(hasScrollBody: false, child: Center(child: child));

    if (!_net.online) return [fill(StatePanel.offline(onAction: _refresh))];

    if (_point == null) {
      if (_locating) return [fill(const _Searching(text: 'Finding your location…'))];
      return [
        fill(switch (_locationProblem) {
          'off' => StatePanel(
              icon: Icons.location_off_outlined,
              title: 'Location is off',
              message: 'Turn on location to see your street in the past, or search any place by name.',
              actionLabel: 'Open settings',
              onAction: () => Geolocator.openLocationSettings(),
              secondaryLabel: 'Search a place',
              onSecondary: _search,
            ),
          'forever' => StatePanel(
              icon: Icons.location_disabled_outlined,
              title: 'Location permission is blocked',
              message: 'Allow location for Ghost City in your phone’s Settings, or search any place by name.',
              actionLabel: 'Open app settings',
              onAction: () => Geolocator.openAppSettings(),
              secondaryLabel: 'Search a place',
              onSecondary: _search,
            ),
          'denied' => StatePanel(
              icon: Icons.near_me_disabled_outlined,
              title: 'See where you stand',
              message: 'Ghost City uses your location only to find old photos of the street you are on.',
              actionLabel: 'Allow location',
              onAction: _locate,
              secondaryLabel: 'Search a place',
              onSecondary: _search,
            ),
          _ => StatePanel(
              icon: Icons.gps_off_rounded,
              title: 'Couldn’t find you',
              message: 'Your phone didn’t return a location. Step outside or search a place by name.',
              actionLabel: 'Try again',
              onAction: _locate,
              secondaryLabel: 'Search a place',
              onSecondary: _search,
            ),
        }),
      ];
    }

    if (_tab == _Tab.satellite) return _satelliteBody();

    final load = _tab == _Tab.street ? _street : _photos;
    if (load.status == _Status.idle || load.status == _Status.loading) {
      return [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), sliver: _SkeletonGrid()),
      ];
    }
    if (load.status == _Status.error) {
      final e = load.error!;
      return [
        fill(StatePanel(
          icon: e.failure == ApiFailure.offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
          title: e.failure == ApiFailure.offline ? 'Connection lost' : 'Couldn’t load photos',
          message: e.message,
          actionLabel: 'Try again',
          onAction: () => _loadCurrentTab(force: true),
          color: GC.coral,
        )),
      ];
    }

    final range = _ages[_age];
    final all = load.data ?? const <PastPhoto>[];
    final list = all.where((p) => p.yearsAgo >= range.min && p.yearsAgo <= range.max).toList();
    if (list.isEmpty) {
      final street = _tab == _Tab.street;
      return [
        fill(StatePanel(
          icon: street ? Icons.streetview_rounded : Icons.photo_library_outlined,
          title: all.isEmpty ? 'Nothing this old here yet' : 'No photos in this range',
          message: all.isEmpty
              ? (street
                  ? 'No street photos older than 5 years were found within 1.5 km. Try Photos or Satellite, which covers every place.'
                  : 'No dated photos older than 5 years were found within 10 km. Satellite images cover every place.')
              : 'Try another age range to see the ${all.length} photos found here.',
          actionLabel: all.isEmpty ? 'Show satellite' : 'Show all ages',
          onAction: all.isEmpty ? () => _selectTab(_Tab.satellite) : () => setState(() => _age = 0),
          secondaryLabel: all.isEmpty ? (street ? 'Try Photos' : 'Try Street') : null,
          onSecondary: all.isEmpty ? () => _selectTab(street ? _Tab.photos : _Tab.street) : null,
        )),
      ];
    }

    final years = list.map((p) => p.year).toList()..sort();
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        sliver: SliverToBoxAdapter(
          child: Text(
            '${list.length} ${list.length == 1 ? 'photo' : 'photos'} · ${years.first == years.last ? '${years.first}' : '${years.first}–${years.last}'}',
            style: GC.body(13, color: GC.muted, weight: FontWeight.w600),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.76,
          ),
          itemCount: list.length,
          itemBuilder: (_, i) => _PhotoCard(
            photo: list[i],
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PhotoViewerScreen(photos: list, initialIndex: i),
            )),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Text(
            _tab == _Tab.street
                ? 'Street photos by Mapillary contributors, CC BY-SA 4.0.'
                : 'Photos from Wikimedia Commons. Licences shown on each photo.',
            style: GC.body(12, color: GC.faint),
          ),
        ),
      ),
    ];
  }

  List<Widget> _satelliteBody() {
    Widget fill(Widget child) => SliverFillRemaining(hasScrollBody: false, child: Center(child: child));
    if (_sat.status == _Status.idle || _sat.status == _Status.loading) {
      return [fill(const _Searching(text: 'Loading the satellite archive…'))];
    }
    if (_sat.status == _Status.error) {
      return [
        fill(StatePanel(
          icon: Icons.cloud_off_rounded,
          title: 'Couldn’t load satellite years',
          message: _sat.error!.message,
          actionLabel: 'Try again',
          onAction: () => _loadSatellite(force: true),
          color: GC.coral,
        )),
      ];
    }
    final releases = _sat.data!;
    if (releases.isEmpty) {
      return [
        fill(const StatePanel(
          icon: Icons.satellite_alt_rounded,
          title: 'No satellite years available',
          message: 'The satellite archive returned no images. Try again later.',
        )),
      ];
    }
    final oldest = releases.first;
    void open(Release r) => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SatelliteScreen(center: _point!, releases: releases, initial: r, placeName: _name),
        ));

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        sliver: SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () => open(oldest),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GC.radiusL + 2),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    IgnorePointer(
                      child: FlutterMap(
                        key: ValueKey(_point),
                        options: MapOptions(
                          initialCenter: _point!,
                          initialZoom: 17,
                          backgroundColor: GC.surface2,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: oldest.urlTemplate,
                            userAgentPackageName: 'com.ghostcity.ghost_city',
                            maxNativeZoom: 19,
                          ),
                        ],
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Color(0x00000000), Color(0xE60F0E0C)],
                          stops: [0, 0.4, 1],
                        ),
                      ),
                    ),
                    const Center(child: Icon(Icons.add_rounded, color: GC.amber, size: 30)),
                    Positioned(top: 14, left: 14, child: Pill(label: 'Satellite · ${oldest.date.year}', background: const Color(0xCC0F0E0C))),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${DateTime.now().year - oldest.date.year} years ago, from above',
                              style: GC.display(24, height: 1.15)),
                          const SizedBox(height: 4),
                          Text('Tap to compare ${oldest.date.year} with today, side by side.',
                              style: GC.body(14, color: GC.textSoft, height: 1.35)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
        sliver: SliverToBoxAdapter(child: SectionLabel('Pick a year · ${releases.length} available')),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in releases)
                ChoiceChipX(label: '${r.date.year}', selected: false, solid: true, onTap: () => open(r)),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Text('Satellite imagery: Esri World Imagery Wayback (Maxar, Earthstar Geographics and others).',
              style: GC.body(12, color: GC.faint)),
        ),
      ),
    ];
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.tooltip, required this.onTap, this.busy = false});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: GC.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: GC.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(strokeWidth: 2, color: GC.amber),
                  )
                : Icon(icon, color: GC.text, size: 21),
          ),
        ),
      ),
    );
  }
}

class _Searching extends StatelessWidget {
  const _Searching({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, color: GC.amber)),
        const SizedBox(height: 16),
        Text(text, style: GC.body(14.5, color: GC.muted)),
      ],
    );
  }
}

class _SkeletonGrid extends StatefulWidget {
  @override
  State<_SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<_SkeletonGrid> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => FadeTransition(
        opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
        child: Container(
          decoration: BoxDecoration(
            color: GC.surface2,
            borderRadius: BorderRadius.circular(GC.radiusL),
            border: Border.all(color: GC.line),
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.photo, required this.onTap});
  final PastPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = photo.distanceMeters;
    final dist = d < 1000 ? '${d.round()} m' : '${(d / 1000).toStringAsFixed(1)} km';
    return Material(
      color: GC.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusL)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'past-${photo.id}',
              child: Image.network(
                photo.thumbUrl,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) => progress == null ? child : const ColoredBox(color: GC.surface2),
                errorBuilder: (context, error, stack) => const ColoredBox(
                  color: GC.surface2,
                  child: Center(child: Icon(Icons.broken_image_outlined, color: GC.faint)),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x59000000), Color(0x00000000), Color(0xF20F0E0C)],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xB30F0E0C), borderRadius: BorderRadius.circular(99)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.place_outlined, size: 12, color: GC.amberLight),
                  const SizedBox(width: 3),
                  Text(dist, style: GC.body(11, color: GC.amberLight, weight: FontWeight.w700, height: 1)),
                ]),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${photo.dateIsUpload ? '~' : ''}${photo.year}', style: GC.display(26, height: 1)),
                  const SizedBox(height: 3),
                  Text('${photo.yearsAgo} years ago',
                      style: GC.body(12.5, color: GC.amber, weight: FontWeight.w700, height: 1.2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
