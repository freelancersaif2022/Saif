import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../services/archive_api.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'lens_screen.dart';

/// Full-screen, swipeable viewer for photos found near a place.
class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({super.key, required this.photos, this.initialIndex = 0});
  final List<PastPhoto> photos;
  final int initialIndex;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  bool _chrome = true;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final p = widget.photos[_index];
    final d = p.distanceMeters;
    final dist = d < 1000 ? '${d.round()} m away' : '${(d / 1000).toStringAsFixed(1)} km away';
    final date = p.dateIsUpload ? 'Uploaded ${p.year}' : '${_month(p.date.month)} ${p.year}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pages,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final photo = widget.photos[i];
                return GestureDetector(
                  onTap: () => setState(() => _chrome = !_chrome),
                  child: InteractiveViewer(
                    maxScale: 5,
                    child: Center(
                      child: Hero(
                        tag: 'past-${photo.id}',
                        child: Image.network(
                          photo.imageUrl,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            final total = progress.expectedTotalBytes;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(photo.thumbUrl, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
                                CircularProgressIndicator(
                                  value: total == null ? null : progress.cumulativeBytesLoaded / total,
                                  strokeWidth: 2.5,
                                  color: GC.amber,
                                ),
                              ],
                            );
                          },
                          errorBuilder: (context, error, stack) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.broken_image_outlined, color: GC.muted, size: 40),
                              const SizedBox(height: 10),
                              Text('This photo could not load', style: GC.body(14, color: GC.muted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedOpacity(
              opacity: _chrome ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_chrome,
                child: Stack(
                  children: [
                    Positioned(
                      top: pad.top + 10,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          GlassIconButton(icon: Icons.close_rounded, tooltip: 'Close', onPressed: () => Navigator.of(context).pop()),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0x8C0F0E0C),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: const Color(0x33F3EBDD)),
                            ),
                            child: Text('${_index + 1} / ${widget.photos.length}',
                                style: GC.body(13, color: GC.text, weight: FontWeight.w700, height: 1)),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: pad.bottom + 14,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xE6141210),
                          borderRadius: BorderRadius.circular(GC.radiusL),
                          border: Border.all(color: GC.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(date.toUpperCase(), style: GC.label(color: GC.amber, size: 10.5)),
                                      const SizedBox(height: 4),
                                      Text(
                                        p.title ?? (p.source == PhotoSource.mapillary ? 'Street photo' : 'Archive photo'),
                                        style: GC.display(19, height: 1.2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${p.yearsAgo}', style: GC.display(30, color: GC.amber, height: 1)),
                                    Text('YEARS AGO', style: GC.label(size: 10)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('$dist · ${p.credit}${p.license == null ? '' : ' · ${p.license}'}',
                                maxLines: 2, overflow: TextOverflow.ellipsis, style: GC.body(12.5, color: GC.muted, height: 1.35)),
                            if (p.dateIsUpload) ...[
                              const SizedBox(height: 4),
                              Text('The archive only lists the upload date; the photo may be older.',
                                  style: GC.body(12, color: GC.faint, height: 1.35)),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: IconButton.outlined(
                                    tooltip: 'Copy source link',
                                    icon: const Icon(Icons.link_rounded, color: GC.text),
                                    style: IconButton.styleFrom(
                                      side: const BorderSide(color: GC.lineStrong),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM)),
                                    ),
                                    onPressed: p.pageUrl == null
                                        ? null
                                        : () {
                                            Clipboard.setData(ClipboardData(text: p.pageUrl!));
                                            showToast('Link copied', context: context, kind: ToastKind.success,
                                                message: 'Paste it in your browser to see the original.');
                                          },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: PrimaryButton(
                                    label: 'Compare with camera',
                                    icon: Icons.center_focus_strong_rounded,
                                    height: 50,
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => LensScreen(photo: p)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _month(int m) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}
