import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app/theme.dart';
import '../services/archive_api.dart';
import '../services/connectivity.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';

/// Satellite view of a place: an archived year on one side of the divider and
/// today on the other. Pan and zoom move both together.
class SatelliteScreen extends StatefulWidget {
  const SatelliteScreen({super.key, required this.center, required this.releases, required this.initial, this.placeName});
  final LatLng center;
  final List<Release> releases;
  final Release initial;
  final String? placeName;

  @override
  State<SatelliteScreen> createState() => _SatelliteScreenState();
}

class _SatelliteScreenState extends State<SatelliteScreen> {
  final _net = ConnectivityService.instance;
  late Release _then = widget.initial;
  late final Release _now = widget.releases.last;
  final _split = ValueNotifier<double>(0.5);

  @override
  void initState() {
    super.initState();
    _net.addListener(_onNet);
  }

  @override
  void dispose() {
    _net.removeListener(_onNet);
    _split.dispose();
    super.dispose();
  }

  void _onNet() => mounted ? setState(() {}) : null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final years = DateTime.now().year - _then.date.year;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (!_net.online)
              Positioned.fill(
                child: ColoredBox(
                  color: GC.ground,
                  child: Center(child: StatePanel.offline(onAction: () => _net.refresh())),
                ),
              )
            else ...[
              FlutterMap(
                options: MapOptions(
                  initialCenter: widget.center,
                  initialZoom: 17,
                  minZoom: 3,
                  maxZoom: 19,
                  backgroundColor: const Color(0xFF14130F),
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                ),
                children: [
                  // Today underneath, the chosen year clipped to the left of the divider.
                  TileLayer(
                    key: ValueKey('now-${_now.urlTemplate}'),
                    urlTemplate: _now.urlTemplate,
                    userAgentPackageName: 'com.ghostcity.ghost_city',
                    maxNativeZoom: 19,
                  ),
                  ClipRect(
                    clipper: _LeftOf(_split),
                    child: TileLayer(
                      key: ValueKey('then-${_then.urlTemplate}'),
                      urlTemplate: _then.urlTemplate,
                      userAgentPackageName: 'com.ghostcity.ghost_city',
                      maxNativeZoom: 19,
                    ),
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: widget.center,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: GC.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 8)],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
              Positioned.fill(
                child: ValueListenableBuilder<double>(
                  valueListenable: _split,
                  builder: (context, split, _) {
                    final x = size.width * split;
                    return Stack(children: [
                      Positioned(left: x - 1, top: 0, bottom: 0, child: const IgnorePointer(child: ColoredBox(color: Colors.white, child: SizedBox(width: 2)))),
                      Positioned(
                        left: x - 48,
                        top: pad.top + 110,
                        bottom: 230,
                        width: 96,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          dragStartBehavior: DragStartBehavior.down,
                          onHorizontalDragStart: (_) => HapticFeedback.selectionClick(),
                          onHorizontalDragUpdate: (d) => _split.value = (d.globalPosition.dx / size.width).clamp(0.0, 1.0),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Color(0x73000000), blurRadius: 20, offset: Offset(0, 6))],
                              ),
                              child: const Icon(Icons.compare_arrows_rounded, color: GC.onAmber),
                            ),
                          ),
                        ),
                      ),
                    ]);
                  },
                ),
              ),
              Positioned(top: pad.top + 70, left: 16, child: IgnorePointer(child: _Tag('${_then.date.year}', amber: true))),
              Positioned(top: pad.top + 70, right: 16, child: IgnorePointer(child: _Tag('${_now.date.year}', amber: false))),
            ],

            Positioned(
              top: pad.top + 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.placeName ?? 'Satellite view',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GC.display(19).copyWith(shadows: const [Shadow(color: Colors.black, blurRadius: 12)]),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 14,
              right: 14,
              bottom: pad.bottom + 14,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: const Color(0xF7141210),
                  borderRadius: BorderRadius.circular(GC.radiusL),
                  border: Border.all(color: GC.line),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('THEN · LEFT OF THE LINE', style: GC.label(color: GC.amber, size: 10.5)),
                              const SizedBox(height: 4),
                              Text('${_then.date.year} vs ${_now.date.year}', style: GC.display(22, height: 1.1)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$years', style: GC.display(28, color: GC.amber, height: 1)),
                            Text('YEARS AGO', style: GC.label(size: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.releases.length - 1,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final r = widget.releases[i];
                          return ChoiceChipX(
                            label: '${r.date.year}',
                            selected: r == _then,
                            solid: true,
                            onTap: () => setState(() => _then = r),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Drag the line to compare · pinch to zoom · Imagery © Esri, Maxar, Earthstar Geographics',
                        style: GC.body(11, color: GC.faint, height: 1.3)),
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

class _LeftOf extends CustomClipper<Rect> {
  _LeftOf(this.split) : super(reclip: split);
  final ValueListenable<double> split;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width * split.value, size.height);

  @override
  bool shouldReclip(_LeftOf old) => old.split != split;
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {required this.amber});
  final String text;
  final bool amber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: amber ? GC.amber : const Color(0xB3000000), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GC.label(color: amber ? GC.onAmber : GC.text, size: 11)),
    );
  }
}
