import 'package:flutter/widgets.dart';

import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/progress_controller.dart';
import '../services/purchase_service.dart';
import '../services/reward_service.dart';

/// Holder for every app-wide service. Filled in by the splash bootstrap.
class AppServices {
  late ProgressController progress;
  late RewardService rewards;
  late AudioService audio;
  late PurchaseService purchases;
  late AdService ads;
  bool ready = false;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.services != services;
}
