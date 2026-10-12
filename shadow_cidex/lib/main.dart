import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/save_data.dart';
import 'ui/splash_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SaveData.instance.load();
  runApp(const ShadowCidexApp());
}

class ShadowCidexApp extends StatelessWidget {
  const ShadowCidexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Cidex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: UiColors.bg,
        fontFamily: 'Rajdhani',
        colorScheme: const ColorScheme.dark(primary: UiColors.accent, secondary: UiColors.red),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const SplashScreen(),
    );
  }
}
