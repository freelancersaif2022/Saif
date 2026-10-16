import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'archive_api.dart';
import 'connectivity.dart';

enum LocationProblem { off, denied, blocked, failed }

/// The phone's position, shared by Near me, Explore, Walks and the recorder.
/// When location is off or not allowed, it tries again by itself as soon as
/// the user comes back to the app (for example from the Settings screen).
class LocationService extends ChangeNotifier with WidgetsBindingObserver {
  LocationService._() {
    WidgetsBinding.instance.addObserver(this);
    ConnectivityService.instance.addListener(_onNetwork);
  }
  static final instance = LocationService._();

  final _api = ArchiveApi();

  LatLng? point;
  String? name;
  LocationProblem? problem;
  bool locating = false;
  bool _started = false;

  /// Bumps every time the position changes enough to reload nearby content.
  int version = 0;

  void ensureStarted() {
    if (_started) return;
    _started = true;
    locate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _started && !locating && (point == null || problem != null)) {
      locate();
    }
  }

  void _onNetwork() {
    if (ConnectivityService.instance.online && point != null && name == null) _loadName();
  }

  Future<void> locate() async {
    if (locating) return;
    locating = true;
    if (point == null) problem = null;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (point == null) problem = LocationProblem.off;
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        if (point == null) problem = LocationProblem.blocked;
        return;
      }
      if (perm == LocationPermission.denied) {
        if (point == null) problem = LocationProblem.denied;
        return;
      }
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && point == null) _set(LatLng(last.latitude, last.longitude));
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      _set(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      if (point == null) problem = LocationProblem.failed;
    } finally {
      locating = false;
      notifyListeners();
    }
  }

  void _set(LatLng p) {
    final moved = point == null || const Distance().as(LengthUnit.Meter, point!, p) > 80;
    problem = null;
    if (!moved) return;
    point = p;
    name = null;
    version++;
    notifyListeners();
    _loadName();
  }

  Future<void> _loadName() async {
    final p = point;
    if (p == null || !ConnectivityService.instance.online) return;
    try {
      final n = await _api.placeName(p);
      if (n != null && p == point) {
        name = n;
        notifyListeners();
      }
    } catch (_) {}
  }

  static Future<void> openSettingsFor(LocationProblem problem) =>
      problem == LocationProblem.off ? Geolocator.openLocationSettings() : Geolocator.openAppSettings();
}
