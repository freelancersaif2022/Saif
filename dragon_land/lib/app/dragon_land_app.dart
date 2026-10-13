import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import 'app_scope.dart';
import 'app_theme.dart';

class DragonLandApp extends StatefulWidget {
  const DragonLandApp({super.key, this.platformServices = true, this.services});

  final bool platformServices;

  /// Pre-built services (tests); otherwise the splash screen creates them.
  final AppServices? services;

  @override
  State<DragonLandApp> createState() => _DragonLandAppState();
}

class _DragonLandAppState extends State<DragonLandApp> {
  late final AppServices _services = widget.services ?? AppServices();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: _services,
      child: MaterialApp(
        title: 'Dragon Land',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: SplashScreen(platformServices: widget.platformServices),
      ),
    );
  }
}
