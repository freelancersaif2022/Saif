import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme.dart';
import 'data/app_state.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/connectivity.dart';
import 'widgets/feedback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final prefs = await SharedPreferences.getInstance();
  runApp(GhostCityApp(state: AppState(prefs)));
}

class GhostCityApp extends StatelessWidget {
  const GhostCityApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Ghost City',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: messengerKey,
        theme: GC.theme(),
        builder: (context, child) {
          // Keep layouts intact on phones with very large accessibility text.
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.25)),
            child: child!,
          );
        },
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  final _net = ConnectivityService.instance;
  bool? _wasOnline;

  @override
  void initState() {
    super.initState();
    _net.addListener(_onNetwork);
    _net.start();
  }

  @override
  void dispose() {
    _net.removeListener(_onNetwork);
    super.dispose();
  }

  /// One calm notice when the connection drops, and one when it comes back.
  void _onNetwork() {
    final online = _net.online;
    if (_wasOnline == online) return;
    final first = _wasOnline == null;
    _wasOnline = online;
    if (!online) {
      showToast(
        'No internet connection',
        kind: ToastKind.offline,
        message: 'Photos and maps need a connection. Saved places and memories still work.',
        actionLabel: 'Retry',
        onAction: () async {
          if (!await _net.refresh()) {
            showToast('Still offline', kind: ToastKind.offline, message: 'Check Wi-Fi or mobile data.');
          }
        },
        duration: const Duration(seconds: 6),
      );
    } else if (!first) {
      showToast('Back online', kind: ToastKind.success, message: 'Photos and maps are loading again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: state.onboarded ? const HomeShell(key: ValueKey('home')) : const OnboardingScreen(key: ValueKey('welcome')),
    );
  }
}
