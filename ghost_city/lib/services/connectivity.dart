import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks whether the phone can actually reach the internet, not just whether
/// Wi-Fi or mobile data is switched on.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();
  static final instance = ConnectivityService._();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _retry;
  bool _online = true;
  bool _checked = false;

  bool get online => _online;
  bool get checked => _checked;

  Future<void> start() async {
    _sub ??= _connectivity.onConnectivityChanged.listen((_) => refresh());
    await refresh();
  }

  /// Re-checks reachability and returns the result.
  Future<bool> refresh() async {
    final results = await _connectivity.checkConnectivity().catchError((_) => <ConnectivityResult>[]);
    final hasLink = results.any((r) => r != ConnectivityResult.none);
    final reachable = hasLink && await _canReachInternet();
    _set(reachable);
    return reachable;
  }

  Future<bool> _canReachInternet() async {
    for (final host in const ['graph.mapillary.com', 'commons.wikimedia.org', 'one.one.one.one']) {
      try {
        final r = await InternetAddress.lookup(host).timeout(const Duration(seconds: 4));
        if (r.isNotEmpty && r.first.rawAddress.isNotEmpty) return true;
      } catch (_) {}
    }
    return false;
  }

  void _set(bool value) {
    _retry?.cancel();
    // While offline, keep checking quietly so the app notices when the connection returns.
    if (!value) _retry = Timer(const Duration(seconds: 6), refresh);
    if (_checked && value == _online) return;
    _checked = true;
    _online = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _retry?.cancel();
    super.dispose();
  }
}
