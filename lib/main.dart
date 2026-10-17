import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/ads/ad_service.dart';
import 'services/game_store.dart';
import 'services/iap/iap_service.dart';
import 'services/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final store = await GameStore.load();
  await Sfx.init(store);
  runApp(VoiceBeastApp(store: store));

  // Network-dependent services start after the first frame so the app
  // opens instantly, online or offline.
  AdService.instance.init(store);
  IapService.instance.init(store);
}
