import 'package:flutter/material.dart';

import '../screens/coin_shop_screen.dart';
import '../screens/daily_rewards_screen.dart';
import '../screens/dragon_select_screen.dart';
import '../screens/dragon_shop_screen.dart';
import '../screens/gameplay_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/lobby_screen.dart';
import '../screens/missions_screen.dart';
import '../screens/settings_screen.dart';

/// Central navigation with soft fade/scale transitions.
class Routes {
  Routes._();

  static PageRoute<T> _fade<T>(Widget page, {String? name}) => PageRouteBuilder<T>(
    settings: RouteSettings(name: name),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 1.04, end: 1.0).animate(curved), child: child),
      );
    },
  );

  static Future<void> lobby(BuildContext c) => Navigator.of(c).pushAndRemoveUntil(_fade(const LobbyScreen(), name: 'lobby'), (_) => false);

  /// Returns to the lobby and opens the Dragon Shop on top of it.
  static void lobbyThenDragonShop(BuildContext c) {
    final nav = Navigator.of(c);
    nav.pushAndRemoveUntil(_fade(const LobbyScreen(), name: 'lobby'), (_) => false);
    nav.push(_fade(const DragonShopScreen(), name: 'dragonShop'));
  }

  static Future<void> play(BuildContext c) => Navigator.of(c).push(_fade(const GameplayScreen(), name: 'play'));
  static Future<void> replacePlay(BuildContext c) => Navigator.of(c).pushReplacement(_fade(const GameplayScreen(), name: 'play'));
  static Future<void> dragonShop(BuildContext c) => Navigator.of(c).push(_fade(const DragonShopScreen(), name: 'dragonShop'));
  static Future<void> selectDragon(BuildContext c) => Navigator.of(c).push(_fade(const DragonSelectScreen(), name: 'select'));
  static Future<void> coinShop(BuildContext c, {int tab = 0}) =>
      Navigator.of(c).push(_fade(CoinShopScreen(initialTab: tab), name: 'coinShop'));
  static Future<void> daily(BuildContext c) => Navigator.of(c).push(_fade(const DailyRewardsScreen(), name: 'daily'));
  static Future<void> missions(BuildContext c) => Navigator.of(c).push(_fade(const MissionsScreen(), name: 'missions'));
  static Future<void> settings(BuildContext c) => Navigator.of(c).push(_fade(const SettingsScreen(), name: 'settings'));
  static Future<void> legal(BuildContext c, LegalPage page) => Navigator.of(c).push(_fade(LegalScreen(page: page), name: 'legal'));
}
