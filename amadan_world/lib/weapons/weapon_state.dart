import 'weapon_data.dart';

/// Runtime ammunition, cooldown and reload state for the player's weapon.
class WeaponState {
  WeaponState(this.spec) : ammo = spec.magazine;

  WeaponSpec spec;
  int ammo;
  double cooldown = 0;
  double reloadTimer = 0;
  double bloom = 0;

  bool get reloading => reloadTimer > 0;

  double get reloadProgress => reloading ? 1 - reloadTimer / spec.reloadTime : 0;

  bool get canFire => !reloading && cooldown <= 0 && ammo > 0;

  bool get needsReload => ammo < spec.magazine;

  void reset() {
    ammo = spec.magazine;
    cooldown = 0;
    reloadTimer = 0;
    bloom = 0;
  }

  bool startReload() {
    if (reloading || ammo >= spec.magazine) return false;
    reloadTimer = spec.reloadTime;
    return true;
  }

  void consume() {
    ammo -= 1;
    cooldown = spec.fireInterval;
    bloom = (bloom + spec.recoil * 0.018).clamp(0.0, 0.09);
  }

  /// Advances timers. Returns true on the frame a reload completes.
  bool update(double dt) {
    if (cooldown > 0) cooldown -= dt;
    bloom = (bloom - dt * 0.12).clamp(0.0, 1.0);
    if (reloadTimer > 0) {
      reloadTimer -= dt;
      if (reloadTimer <= 0) {
        reloadTimer = 0;
        ammo = spec.magazine;
        return true;
      }
    }
    return false;
  }
}
