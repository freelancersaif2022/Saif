import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../services/archive_api.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'explore_screen.dart';
import 'nearby_screen.dart';
import 'record_screen.dart';

/// Detail page for a place near the user (same design as the classic places).
class NearbyPlaceScreen extends StatelessWidget {
  const NearbyPlaceScreen({super.key, required this.place});
  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final saved = state.isPlaceSaved(place.id);
    final h = MediaQuery.sizeOf(context).height;
    final mine = state.memories.where((m) => m.placeName == place.title).toList();

    return Scaffold(
      backgroundColor: GC.ground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: h * 0.5,
            pinned: true,
            stretch: true,
            backgroundColor: GC.ground,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
              ),
            ),
            actions: [
              GlassIconButton(
                icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                iconColor: saved ? GC.amber : GC.text,
                tooltip: saved ? 'Remove from saved' : 'Save place',
                onPressed: () {
                  state.togglePlace(place);
                  showToast(saved ? 'Removed from saved' : 'Saved to your places',
                      context: context, kind: saved ? ToastKind.info : ToastKind.success);
                },
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'np-${place.id}', child: PlaceImage(place.imageUrl)),
                  const BottomFade(stops: [0.55, 1.0]),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    Pill(label: distanceLabel(place.distanceMeters)),
                    const Pill(label: 'Wikipedia', background: GC.surface2, foreground: GC.textSoft),
                  ]),
                  const SizedBox(height: 14),
                  Text(place.title, style: GC.display(34, height: 1.08)),
                  if (place.description != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      place.description![0].toUpperCase() + place.description!.substring(1),
                      style: GC.display(19, color: GC.amberLight, style: FontStyle.italic, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'See this place years ago',
                    icon: Icons.history_rounded,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => NearbyScreen(initialPoint: place.point, initialName: place.title),
                    )),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    place.extract ?? 'Wikipedia has no summary for this place yet.',
                    style: GC.body(16, height: 1.65),
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: GC.amber, padding: EdgeInsets.zero),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: place.url));
                      showToast('Link copied', context: context, kind: ToastKind.success, message: 'Paste it in your browser to read the full article.');
                    },
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Copy Wikipedia link'),
                  ),
                  const SizedBox(height: 22),
                  SectionLabel('Your memories here', trailing: mine.isEmpty ? null : Text('${mine.length}', style: GC.label(color: GC.amber))),
                  const SizedBox(height: 12),
                  Material(
                    color: const Color(0x0FE9B44C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GC.radiusM + 2),
                      side: const BorderSide(color: Color(0x66E9B44C)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => openRecorder(context, placeName: place.title),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.mic_none_rounded, color: GC.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mine.isEmpty
                                    ? 'Do you remember this place? Leave a voice memory about it.'
                                    : 'You left ${mine.length} ${mine.length == 1 ? 'memory' : 'memories'} here. Add another.',
                                style: GC.body(14, color: GC.textSoft, height: 1.4),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: GC.amber),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text('Text and photo from Wikipedia and Wikimedia Commons (CC BY-SA).', style: GC.body(12.5, color: GC.faint)),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
