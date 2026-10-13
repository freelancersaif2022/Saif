import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app/app_scope.dart';

/// Banner shown only on menu screens, never during gameplay. Collapses to
/// nothing when ads are removed, unsupported, or the banner fails to load.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad != null) return;
    final ads = AppScope.of(context).ads;
    _ad = ads.createBanner((_) {
      if (mounted) setState(() => _loaded = true);
    });
    _ad?.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return ListenableBuilder(
      listenable: services.progress,
      builder: (context, _) {
        final ad = _ad;
        if (ad == null || !_loaded || services.progress.adsRemoved) return const SizedBox.shrink();
        return SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        );
      },
    );
  }
}
