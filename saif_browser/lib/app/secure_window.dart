import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Reasons to set FLAG_SECURE (no screenshots, blank recent-apps preview).
final secureWindowProvider = NotifierProvider<SecureWindowController, Set<String>>(SecureWindowController.new);

class SecureWindowController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void set(String reason, bool active) {
    final next = {...state};
    if (active) {
      next.add(reason);
    } else {
      next.remove(reason);
    }
    if (next.length == state.length && next.containsAll(state)) return;
    final wasSecure = state.isNotEmpty;
    state = next;
    if (wasSecure != next.isNotEmpty) {
      ref.read(systemBridgeProvider).setSecure(next.isNotEmpty);
    }
  }
}
