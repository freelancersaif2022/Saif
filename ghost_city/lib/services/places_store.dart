import 'package:flutter/foundation.dart';

import 'archive_api.dart';
import 'connectivity.dart';
import 'location.dart';

enum LoadStatus { idle, loading, done, error }

/// Notable places around the phone's position, shared by Explore and Walks.
class PlacesStore extends ChangeNotifier {
  PlacesStore._() {
    _location.addListener(_onChange);
    _net.addListener(_onChange);
  }
  static final instance = PlacesStore._();

  final _api = ArchiveApi();
  final _location = LocationService.instance;
  final _net = ConnectivityService.instance;

  LoadStatus status = LoadStatus.idle;
  NearbyResult? result;
  ApiException? error;
  int _loadedVersion = -1;

  void _onChange() {
    if (_location.version != _loadedVersion && _location.point != null) {
      load();
    } else if (_net.online && status == LoadStatus.error && error?.failure == ApiFailure.offline) {
      load(force: true);
    }
  }

  Future<void> load({bool force = false}) async {
    final p = _location.point;
    if (p == null) return;
    if (!force && status == LoadStatus.loading) return;
    if (!force && status == LoadStatus.done && _loadedVersion == _location.version) return;
    if (!_net.online) {
      status = LoadStatus.error;
      error = ApiException(ApiFailure.offline);
      notifyListeners();
      return;
    }
    final version = _location.version;
    status = LoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      final r = await _api.nearbyPlaces(p);
      if (version != _location.version) return;
      result = r;
      _loadedVersion = version;
      status = LoadStatus.done;
    } on ApiException catch (e) {
      error = e;
      status = LoadStatus.error;
      if (e.failure == ApiFailure.offline) _net.refresh();
    }
    notifyListeners();
  }
}
