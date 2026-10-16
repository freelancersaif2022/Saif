import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'lens_screen.dart';
import 'memories_screen.dart';
import 'paywall_screen.dart';
import 'record_screen.dart';
import 'story_screen.dart';

class PlaceScreen extends StatelessWidget {
  const PlaceScreen({super.key, required this.place});
  final Place place;

  void _openStory(BuildContext context, Story s) {
    final state = AppScope.read(context);
    if (s.premium && !state.premium) {
      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryScreen(place: place, story: s)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final saved = state.isSaved(place.id);
    final mine = state.memories.where((m) => m.placeId == place.id).toList();
    final h = MediaQuery.sizeOf(context).height;

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
                child: GlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              GlassIconButton(
                icon: Icons.zoom_out_map_rounded,
                tooltip: 'View full photo',
                onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, _, _) => _PhotoViewer(place: place),
                  transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
                )),
              ),
              const SizedBox(width: 10),
              GlassIconButton(
                icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                iconColor: saved ? GC.amber : GC.text,
                tooltip: saved ? 'Remove from saved' : 'Save place',
                onPressed: () {
                  state.toggleSaved(place.id);
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
                  Hero(tag: 'photo-${place.id}', child: ArchivePhoto(place.image)),
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
                    Pill(label: place.dateLabel),
                    Pill(
                      label: '${place.yearsAgo} years ago',
                      background: GC.surface2,
                      foreground: GC.textSoft,
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Text(place.name, style: GC.display(34, height: 1.08)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 17, color: GC.amber),
                    const SizedBox(width: 5),
                    Text(place.location, style: GC.body(14, color: GC.muted)),
                  ]),
                  const SizedBox(height: 18),
                  Text(place.tagline, style: GC.display(19, color: GC.amberLight, style: FontStyle.italic, height: 1.35)),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Open Time Lens here',
                    icon: Icons.center_focus_strong_rounded,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LensScreen(place: place))),
                  ),
                  const SizedBox(height: 28),
                  Text(place.summary, style: GC.body(16, height: 1.65)),
                  const SizedBox(height: 30),
                  const SectionLabel('Stories at this spot'),
                  const SizedBox(height: 12),
                  for (final s in place.stories) ...[
                    _StoryTile(story: s, locked: s.premium && !state.premium, onTap: () => _openStory(context, s)),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 20),
                  const SectionLabel('Then & now'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: GC.surface,
                      borderRadius: BorderRadius.circular(GC.radiusL),
                      border: Border.all(color: GC.line),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < place.facts.length; i++) ...[
                          if (i > 0) const Divider(height: 22, color: GC.line),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 7),
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(color: GC.amber, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(place.facts[i], style: GC.body(15, color: GC.text, height: 1.45))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SectionLabel('Your memories here', trailing: mine.isEmpty ? null : Text('${mine.length}', style: GC.label(color: GC.amber))),
                  const SizedBox(height: 12),
                  if (mine.isEmpty)
                    _AddMemoryCard(place: place)
                  else
                    for (final m in mine) ...[MemoryTile(memory: m), const SizedBox(height: 10)],
                  const SizedBox(height: 26),
                  Text(place.credit, style: GC.body(12.5, color: GC.faint)),
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

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story, required this.locked, required this.onTap});
  final Story story;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM + 2), side: const BorderSide(color: GC.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: locked ? GC.surface3 : GC.amber,
                  shape: BoxShape.circle,
                ),
                child: Icon(locked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                    color: locked ? GC.amberLight : GC.onAmber, size: locked ? 20 : 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(story.title, style: GC.display(17, height: 1.2)),
                    const SizedBox(height: 4),
                    Text('${story.year} · ${story.minutes} min narration', style: GC.body(13, color: GC.muted, height: 1.2)),
                  ],
                ),
              ),
              if (locked) const PremiumBadge(compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMemoryCard extends StatelessWidget {
  const _AddMemoryCard({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x0FE9B44C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GC.radiusM + 2),
        side: const BorderSide(color: Color(0x66E9B44C)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openRecorder(context, place: place),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.mic_none_rounded, color: GC.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Do you remember this place? Leave a voice memory pinned right here.',
                    style: GC.body(14, color: GC.textSoft, height: 1.4)),
              ),
              const Icon(Icons.chevron_right_rounded, color: GC.amber),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.96),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(child: ArchivePhoto(place.image, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: pad.top + 10,
            left: 16,
            child: GlassIconButton(icon: Icons.close_rounded, tooltip: 'Close', onPressed: () => Navigator.of(context).pop()),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: pad.bottom + 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: GC.display(20)),
                const SizedBox(height: 4),
                Text('${place.location} · ${place.dateLabel}', style: GC.body(13, color: GC.muted)),
                const SizedBox(height: 2),
                Text(place.credit, style: GC.body(12, color: GC.faint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
