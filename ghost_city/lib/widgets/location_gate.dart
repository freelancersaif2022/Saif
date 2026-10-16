import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/connectivity.dart';
import '../services/location.dart';
import 'feedback.dart';

/// Shows the right full-screen state while there is no position or no internet,
/// and [builder] once both are available.
class LocationGate extends StatelessWidget {
  const LocationGate({super.key, required this.builder, this.onSearch, this.needsInternet = true});

  final Widget Function(BuildContext context) builder;
  final VoidCallback? onSearch;
  final bool needsInternet;

  @override
  Widget build(BuildContext context) {
    final loc = LocationService.instance;
    final net = ConnectivityService.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([loc, net]),
      builder: (context, _) {
        if (needsInternet && !net.online) {
          return Center(child: StatePanel.offline(onAction: () => net.refresh()));
        }
        if (loc.point != null) return builder(context);
        if (loc.locating || loc.problem == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, color: GC.amber)),
                const SizedBox(height: 16),
                Text('Finding your location…', style: GC.body(14.5, color: GC.muted)),
              ],
            ),
          );
        }
        return Center(child: LocationProblemPanel(problem: loc.problem!, onSearch: onSearch));
      },
    );
  }
}

class LocationProblemPanel extends StatelessWidget {
  const LocationProblemPanel({super.key, required this.problem, this.onSearch});
  final LocationProblem problem;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final loc = LocationService.instance;
    return switch (problem) {
      LocationProblem.off => StatePanel(
          icon: Icons.location_off_outlined,
          title: 'Location is off',
          message: 'Turn on location and come back. Ghost City will refresh by itself.',
          actionLabel: 'Turn on location',
          onAction: () => LocationService.openSettingsFor(problem),
          secondaryLabel: onSearch == null ? null : 'Search a place',
          onSecondary: onSearch,
        ),
      LocationProblem.blocked => StatePanel(
          icon: Icons.location_disabled_outlined,
          title: 'Location permission is blocked',
          message: 'Allow location for Ghost City in Settings and come back. The app will refresh by itself.',
          actionLabel: 'Open app settings',
          onAction: () => LocationService.openSettingsFor(problem),
          secondaryLabel: onSearch == null ? null : 'Search a place',
          onSecondary: onSearch,
        ),
      LocationProblem.denied => StatePanel(
          icon: Icons.near_me_disabled_outlined,
          title: 'See where you stand',
          message: 'Ghost City uses your location only to find places and old photos around you.',
          actionLabel: 'Allow location',
          onAction: loc.locate,
          secondaryLabel: onSearch == null ? null : 'Search a place',
          onSecondary: onSearch,
        ),
      LocationProblem.failed => StatePanel(
          icon: Icons.gps_off_rounded,
          title: 'Couldn’t find you',
          message: 'Your phone didn’t return a location. Step outside and try again.',
          actionLabel: 'Try again',
          onAction: loc.locate,
          secondaryLabel: onSearch == null ? null : 'Search a place',
          onSecondary: onSearch,
        ),
    };
  }
}
