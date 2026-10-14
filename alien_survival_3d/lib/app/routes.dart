import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final routeObserver = RouteObserver<PageRoute<dynamic>>();

class Routes {
  static const menu = '/menu';
  static const loadout = '/loadout';
  static const game = '/game';
  static const shop = '/shop';
  static const upgrade = '/upgrade';
  static const settings = '/settings';
  static const stats = '/stats';
  static const highScores = '/high-scores';
  static const layoutEditor = '/layout-editor';
}

/// Fade + slight zoom transition used between all screens.
class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, anim, _, child) {
            final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: a,
              child: ScaleTransition(scale: Tween(begin: 1.03, end: 1.0).animate(a), child: child),
            );
          },
        );
}
