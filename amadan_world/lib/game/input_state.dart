/// Touch input shared between the Flutter control overlay and the game loop.
class InputState {
  double moveX = 0;
  double moveY = 0;
  bool fire = false;
  bool sprint = false;
  bool _aimRequested = false;
  bool _reloadRequested = false;

  void requestAimToggle() => _aimRequested = true;

  void requestReload() => _reloadRequested = true;

  bool consumeAimToggle() {
    final v = _aimRequested;
    _aimRequested = false;
    return v;
  }

  bool consumeReload() {
    final v = _reloadRequested;
    _reloadRequested = false;
    return v;
  }

  void setMove(double x, double y) {
    moveX = x;
    moveY = y;
  }

  void reset() {
    moveX = 0;
    moveY = 0;
    fire = false;
    sprint = false;
    _aimRequested = false;
    _reloadRequested = false;
  }
}
