/// Control state written by the on-screen HUD buttons and consumed by the
/// game every frame. Edge-triggered actions are latched until consumed.
class InputState {
  bool left = false;
  bool right = false;

  bool _jump = false;
  bool _fly = false;
  bool _sprint = false;
  bool _attack = false;
  bool _special = false;

  void pressJump() => _jump = true;
  void pressFly() => _fly = true;
  void pressSprint() => _sprint = true;
  void pressAttack() => _attack = true;
  void pressSpecial() => _special = true;

  bool consumeJump() => _take(_jump, () => _jump = false);
  bool consumeFly() => _take(_fly, () => _fly = false);
  bool consumeSprint() => _take(_sprint, () => _sprint = false);
  bool consumeAttack() => _take(_attack, () => _attack = false);
  bool consumeSpecial() => _take(_special, () => _special = false);

  bool _take(bool v, void Function() clear) {
    if (v) clear();
    return v;
  }

  double get horizontal => (right ? 1.0 : 0.0) - (left ? 1.0 : 0.0);

  void reset() {
    left = right = false;
    _jump = _fly = _sprint = _attack = _special = false;
  }
}
