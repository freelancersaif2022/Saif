import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../services/archive_api.dart';
import '../widgets/feedback.dart';
import '../widgets/common.dart';
import 'paywall_screen.dart';
import 'place_screen.dart';
import 'story_screen.dart';

enum LensMode { split, ghost }

/// Live camera with the archive photo laid over it. Drag the divider to reveal
/// the past; pinch or drag the photo to line it up with the real street.
class LensScreen extends StatefulWidget {
  const LensScreen({super.key, this.place, this.photo}) : assert(place != null || photo != null);

  /// A curated place with its bundled archive photo and stories.
  final Place? place;

  /// Or any dated photo found near the user (street photos, Wikimedia).
  final PastPhoto? photo;

  @override
  State<LensScreen> createState() => _LensScreenState();
}

class _LensScreenState extends State<LensScreen> with WidgetsBindingObserver {
  CameraController? _camera;
  String? _cameraError;
  bool _starting = false;
  bool _torch = false;

  LensMode _mode = LensMode.split;
  // Only the clip, line and handle listen to this, so dragging never rebuilds the camera.
  final _split = ValueNotifier<double>(0.5);
  double _ghost = 0.55;

  // Photo alignment (pinch to scale, drag to move).
  double _scale = 1;
  Offset _offset = Offset.zero;
  double _startScale = 1;
  Offset _startFocal = Offset.zero;
  Offset _startOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    _split.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _camera;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (c != null) {
        _camera = null;
        _torch = false;
        c.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _startCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_starting) return;
    _starting = true;
    setState(() => _cameraError = null);
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw CameraException('NoCamera', 'No camera found on this device.');
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final c = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _camera = c);
    } on CameraException catch (e) {
      final denied = e.code.contains('Denied') || e.code.contains('denied');
      if (mounted) {
        setState(() => _cameraError = denied
            ? 'Camera access is off. Allow it in your phone’s Settings to see the past over the present.'
            : (e.description ?? 'The camera could not start.'));
      }
    } catch (_) {
      if (mounted) setState(() => _cameraError = 'The camera could not start on this device.');
    } finally {
      _starting = false;
    }
  }

  Future<void> _toggleTorch() async {
    final c = _camera;
    if (c == null) return;
    try {
      await c.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      setState(() => _torch = !_torch);
    } catch (_) {
      if (mounted) {
        showToast('No torch on this camera', context: context, kind: ToastKind.error);
      }
    }
  }

  void _setMode(LensMode m) {
    if (m == LensMode.ghost && !AppScope.read(context).premium) {
      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()));
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _mode = m);
  }

  void _resetAlignment() {
    HapticFeedback.mediumImpact();
    setState(() {
      _scale = 1;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final net = widget.photo;
    final title = place?.name ?? net!.title ?? (net!.source == PhotoSource.mapillary ? 'Street photo' : 'Archive photo');
    final subtitle = place != null ? '${place.city} · ${place.dateLabel}' : '${net!.source.label} · ${net.year}';
    final year = place?.year ?? net!.year;
    final yearsAgo = place?.yearsAgo ?? net!.yearsAgo;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final premium = AppScope.of(context).premium;

    final photo = Transform.translate(
      offset: _offset,
      child: Transform.scale(
        scale: _scale,
        child: place != null
            ? ArchivePhoto(place.image)
            : Image.network(
                net!.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: GC.amber)),
                errorBuilder: (context, error, stack) => const Center(
                  child: Icon(Icons.broken_image_outlined, color: GC.muted, size: 40),
                ),
              ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Present: the live camera.
            Positioned.fill(child: RepaintBoundary(child: _CameraLayer(controller: _camera, error: _cameraError))),

            // Past: the archive photo, aligned by pinch and drag.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: _resetAlignment,
                onScaleStart: (d) {
                  _startScale = _scale;
                  _startFocal = d.focalPoint;
                  _startOffset = _offset;
                },
                onScaleUpdate: (d) => setState(() {
                  _scale = (_startScale * d.scale).clamp(0.6, 4.0);
                  _offset = _startOffset + (d.focalPoint - _startFocal);
                }),
                child: _mode == LensMode.split
                    ? ClipRect(clipper: _FromLeft(_split), child: RepaintBoundary(child: ColorFiltered(colorFilter: _film, child: photo)))
                    : Opacity(opacity: _ghost, child: ColorFiltered(colorFilter: _film, child: photo)),
              ),
            ),

            if (_cameraError != null)
              Positioned(
                left: 20,
                width: (size.width * 0.5 - 30).clamp(150.0, 400.0),
                top: 0,
                bottom: 0,
                child: Center(child: _CameraError(message: _cameraError!, onRetry: _startCamera)),
              ),

            // Readability shade at the top and bottom.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x8C000000), Color(0x00000000), Color(0x00000000), Color(0xD9000000)],
                      stops: [0, 0.2, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),

            if (_mode == LensMode.split)
              Positioned.fill(
                child: ValueListenableBuilder<double>(
                  valueListenable: _split,
                  builder: (context, split, _) {
                    final x = size.width * split;
                    return Stack(
                      children: [
                        // Divider line.
                        Positioned(
                          left: x - 1,
                          top: 0,
                          bottom: 0,
                          child: const IgnorePointer(child: ColoredBox(color: GC.text, child: SizedBox(width: 2))),
                        ),
                        // Wide, invisible drag strip around the line; the line follows the finger exactly.
                        Positioned(
                          left: x - 48,
                          top: pad.top + 120,
                          bottom: 260,
                          width: 96,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            dragStartBehavior: DragStartBehavior.down,
                            onHorizontalDragStart: (_) => HapticFeedback.selectionClick(),
                            onHorizontalDragUpdate: (d) => _split.value = (d.globalPosition.dx / size.width).clamp(0.0, 1.0),
                            child: Center(
                              child: Semantics(
                                label: 'Drag to compare then and now',
                                slider: true,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: GC.text,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Color(0x73000000), blurRadius: 20, offset: Offset(0, 6))],
                                  ),
                                  child: const Icon(Icons.compare_arrows_rounded, color: GC.onAmber, size: 24),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: pad.top + 74,
                          left: 16,
                          child: IgnorePointer(child: _CornerTag(text: 'TODAY', dark: true, visible: split > 0.18)),
                        ),
                        Positioned(
                          top: pad.top + 74,
                          right: 16,
                          child: IgnorePointer(child: _CornerTag(text: '$year', dark: false, visible: split < 0.82)),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Top bar.
            Positioned(
              top: pad.top + 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  GlassIconButton(icon: Icons.close_rounded, tooltip: 'Close lens', onPressed: () => Navigator.of(context).pop()),
                  const Spacer(),
                  _ModeSwitch(mode: _mode, premium: premium, onChanged: _setMode),
                  const Spacer(),
                  GlassIconButton(
                    icon: _torch ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                    iconColor: _torch ? GC.amber : GC.text,
                    tooltip: 'Torch',
                    onPressed: _camera == null ? null : _toggleTorch,
                  ),
                ],
              ),
            ),

            // Bottom panel.
            Positioned(
              left: 14,
              right: 14,
              bottom: pad.bottom + 14,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: const Color(0xE6141210),
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
                              Text(title, style: GC.display(20, height: 1.15), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(subtitle, style: GC.body(13, color: GC.muted, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$yearsAgo', style: GC.display(28, color: GC.amber, height: 1)),
                            Text('YEARS AGO', style: GC.label(size: 10)),
                          ],
                        ),
                      ],
                    ),
                    if (_mode == LensMode.ghost) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Now', style: GC.body(12, color: GC.muted, weight: FontWeight.w700)),
                          Expanded(
                            child: Slider(
                              value: _ghost,
                              onChanged: (v) => setState(() => _ghost = v),
                              semanticFormatterCallback: (v) => '${(v * 100).round()} percent past',
                            ),
                          ),
                          Text('$year', style: GC.body(12, color: GC.amber, weight: FontWeight.w700)),
                        ],
                      ),
                    ] else
                      const SizedBox(height: 14),
                    if (place == null)
                      Row(
                        children: [
                          Expanded(
                            child: _PanelButton(
                              icon: Icons.info_outline_rounded,
                              label: 'Credit',
                              onTap: () => showToast(
                                net!.credit,
                                context: context,
                                message: [net.license, net.dateIsUpload ? 'Date is the upload date' : null].whereType<String>().join(' · '),
                                duration: const Duration(seconds: 4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              label: 'Re-align photo',
                              icon: Icons.filter_center_focus_rounded,
                              height: 50,
                              onPressed: _resetAlignment,
                            ),
                          ),
                        ],
                      )
                    else
                    Row(
                      children: [
                        Expanded(
                          child: _PanelButton(
                            icon: Icons.info_outline_rounded,
                            label: 'Details',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaceScreen(place: place))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: PrimaryButton(
                            label: 'Listen',
                            icon: Icons.headphones_rounded,
                            height: 50,
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => StoryScreen(place: place, story: place.stories.first),
                            )),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PanelButton(icon: Icons.filter_center_focus_rounded, label: 'Re-align', onTap: _resetAlignment),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text('Pinch or drag the old photo to line it up · double-tap to reset',
                          textAlign: TextAlign.center, style: GC.body(11.5, color: GC.faint, height: 1.3)),
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

  /// Slight warm film tone so the archive photo reads as "the past".
  static const _film = ColorFilter.matrix(<double>[
    1.05, 0.05, 0, 0, 4, //
    0.02, 1.0, 0.02, 0, 0,
    0, 0.04, 0.9, 0, -4,
    0, 0, 0, 1, 0,
  ]);
}

class _CameraLayer extends StatelessWidget {
  const _CameraLayer({required this.controller, required this.error});
  final CameraController? controller;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c != null && c.value.isInitialized && c.value.previewSize != null) {
      final ps = c.value.previewSize!;
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: ps.height, height: ps.width, child: CameraPreview(c)),
        ),
      );
    }
    return Container(
      color: const Color(0xFF151413),
      alignment: const Alignment(-0.5, 0),
      child: error == null
          ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: GC.amber))
          : null,
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.no_photography_outlined, color: GC.muted, size: 30),
        const SizedBox(height: 12),
        Text(message, style: GC.body(13.5, color: GC.textSoft, height: 1.45)),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: GC.amber, padding: EdgeInsets.zero),
          child: const Text('Try again'),
        ),
      ],
    );
  }
}

class _FromLeft extends CustomClipper<Rect> {
  _FromLeft(this.split) : super(reclip: split);
  final ValueListenable<double> split;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(size.width * split.value, 0, size.width, size.height);

  @override
  bool shouldReclip(_FromLeft old) => old.split != split;
}

class _CornerTag extends StatelessWidget {
  const _CornerTag({required this.text, required this.dark, required this.visible});
  final String text;
  final bool dark;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: dark ? const Color(0x8C000000) : GC.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: GC.label(color: dark ? GC.text : GC.onAmber, size: 11)),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.premium, required this.onChanged});
  final LensMode mode;
  final bool premium;
  final ValueChanged<LensMode> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(LensMode m, String label, {bool locked = false}) {
      final on = m == mode;
      return GestureDetector(
        onTap: () => onChanged(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: on ? GC.amber : Colors.transparent, borderRadius: BorderRadius.circular(99)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GC.body(13, color: on ? GC.onAmber : GC.text, weight: FontWeight.w700, height: 1)),
              if (locked) ...[const SizedBox(width: 5), const Icon(Icons.lock_rounded, size: 13, color: GC.amberLight)],
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x8C0F0E0C),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x33F3EBDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg(LensMode.split, 'Split'),
          seg(LensMode.ghost, 'Ghost', locked: !premium),
        ],
      ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GC.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM), side: const BorderSide(color: GC.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: GC.text),
              const SizedBox(height: 3),
              Text(label, style: GC.body(10.5, color: GC.muted, weight: FontWeight.w700, height: 1), maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
