import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'ui/ui_theme.dart';

class AmadanWorldApp extends StatelessWidget {
  const AmadanWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amadan World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: UiColors.accent,
          secondary: UiColors.accentSoft,
          surface: UiColors.panel,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
