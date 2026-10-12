import 'package:flutter/painting.dart';

import '../utils/asset_paths.dart';

enum WeaponType { assaultRifle, smg, shotgun, sniper }

/// Static balancing data for one weapon.
class WeaponSpec {
  const WeaponSpec({
    required this.type,
    required this.name,
    required this.image,
    required this.damage,
    required this.fireInterval,
    required this.magazine,
    required this.reloadTime,
    required this.hipSpread,
    required this.aimSpread,
    required this.recoil,
    required this.range,
    required this.bulletSpeed,
    required this.pellets,
    required this.headshotChance,
    required this.pierce,
    required this.sound,
    required this.shake,
    required this.zoom,
    required this.tracerColor,
    required this.model,
  });

  final WeaponType type;
  final String name;
  final String image;
  final double damage;
  final double fireInterval;
  final int magazine;
  final double reloadTime;
  final double hipSpread;
  final double aimSpread;
  final double recoil;
  final double range;
  final double bulletSpeed;
  final int pellets;
  final double headshotChance;
  final int pierce;
  final String sound;
  final double shake;
  final double zoom;
  final Color tracerColor;
  final WeaponModel model;

  double get roundsPerMinute => 60 / fireInterval;

  static const WeaponSpec assaultRifle = WeaponSpec(
    type: WeaponType.assaultRifle,
    name: 'AR-7 Assault Rifle',
    image: AssetPaths.weaponAssault,
    damage: 26,
    fireInterval: 0.11,
    magazine: 30,
    reloadTime: 1.8,
    hipSpread: 0.05,
    aimSpread: 0.018,
    recoil: 0.55,
    range: 950,
    bulletSpeed: 2600,
    pellets: 1,
    headshotChance: 0.45,
    pierce: 0,
    sound: Sfx.shotAr,
    shake: 1.6,
    zoom: 1.12,
    tracerColor: Color(0xFFFFD27A),
    model: WeaponModel.assault,
  );

  static const WeaponSpec smg = WeaponSpec(
    type: WeaponType.smg,
    name: 'VX-9 Submachine Gun',
    image: AssetPaths.weaponSmg,
    damage: 16,
    fireInterval: 0.066,
    magazine: 40,
    reloadTime: 1.45,
    hipSpread: 0.08,
    aimSpread: 0.04,
    recoil: 0.35,
    range: 620,
    bulletSpeed: 2300,
    pellets: 1,
    headshotChance: 0.3,
    pierce: 0,
    sound: Sfx.shotSmg,
    shake: 1.0,
    zoom: 1.06,
    tracerColor: Color(0xFFFFE6A0),
    model: WeaponModel.smg,
  );

  static const WeaponSpec shotgun = WeaponSpec(
    type: WeaponType.shotgun,
    name: 'K-12 Combat Shotgun',
    image: AssetPaths.weaponShotgun,
    damage: 17,
    fireInterval: 0.72,
    magazine: 8,
    reloadTime: 2.3,
    hipSpread: 0.2,
    aimSpread: 0.14,
    recoil: 1.6,
    range: 430,
    bulletSpeed: 2100,
    pellets: 8,
    headshotChance: 0.15,
    pierce: 0,
    sound: Sfx.shotShotgun,
    shake: 5.0,
    zoom: 1.04,
    tracerColor: Color(0xFFFFC060),
    model: WeaponModel.shotgun,
  );

  static const WeaponSpec sniper = WeaponSpec(
    type: WeaponType.sniper,
    name: 'LR-50 Sniper Rifle',
    image: AssetPaths.weaponSniper,
    damage: 150,
    fireInterval: 1.15,
    magazine: 5,
    reloadTime: 2.7,
    hipSpread: 0.03,
    aimSpread: 0.002,
    recoil: 2.2,
    range: 1700,
    bulletSpeed: 4200,
    pellets: 1,
    headshotChance: 0.85,
    pierce: 2,
    sound: Sfx.shotSniper,
    shake: 6.0,
    zoom: 1.3,
    tracerColor: Color(0xFFFFF4D0),
    model: WeaponModel.sniper,
  );

  static const List<WeaponSpec> all = [assaultRifle, smg, shotgun, sniper];

  static WeaponSpec of(WeaponType type) {
    switch (type) {
      case WeaponType.assaultRifle:
        return assaultRifle;
      case WeaponType.smg:
        return smg;
      case WeaponType.shotgun:
        return shotgun;
      case WeaponType.sniper:
        return sniper;
    }
  }

  /// Normalised 0..1 ratings for the lobby stat bars.
  double get damageRating => ((damage * pellets) / 150).clamp(0.08, 1.0);
  double get fireRateRating => (roundsPerMinute / 900).clamp(0.06, 1.0);
  double get magazineRating => (magazine / 40).clamp(0.08, 1.0);
  double get reloadRating => (1 - (reloadTime - 1.2) / 2.0).clamp(0.08, 1.0);
  double get rangeRating => (range / 1700).clamp(0.08, 1.0);
}

/// Shape data for drawing a weapon in the soldier's hands.
class WeaponModel {
  const WeaponModel({
    required this.length,
    required this.gripAt,
    required this.foreAt,
    required this.magAt,
    required this.magLength,
    required this.thickness,
    required this.scope,
    required this.pump,
    required this.metal,
    required this.furniture,
  });

  final double length;
  final double gripAt;
  final double foreAt;
  final double magAt;
  final double magLength;
  final double thickness;
  final bool scope;
  final bool pump;
  final Color metal;
  final Color furniture;

  static const WeaponModel assault = WeaponModel(
    length: 31,
    gripAt: 0.3,
    foreAt: 0.64,
    magAt: 0.42,
    magLength: 7.5,
    thickness: 3.2,
    scope: false,
    pump: false,
    metal: Color(0xFF2A2C2F),
    furniture: Color(0xFF8A7656),
  );

  static const WeaponModel smg = WeaponModel(
    length: 23,
    gripAt: 0.32,
    foreAt: 0.66,
    magAt: 0.48,
    magLength: 8.5,
    thickness: 3.4,
    scope: false,
    pump: false,
    metal: Color(0xFF232427),
    furniture: Color(0xFF34363A),
  );

  static const WeaponModel shotgun = WeaponModel(
    length: 33,
    gripAt: 0.3,
    foreAt: 0.62,
    magAt: 0.0,
    magLength: 0,
    thickness: 3.6,
    scope: false,
    pump: true,
    metal: Color(0xFF26272A),
    furniture: Color(0xFF6A4228),
  );

  static const WeaponModel sniper = WeaponModel(
    length: 42,
    gripAt: 0.26,
    foreAt: 0.56,
    magAt: 0.36,
    magLength: 5,
    thickness: 3.2,
    scope: true,
    pump: false,
    metal: Color(0xFF222326),
    furniture: Color(0xFF4A533A),
  );

  static const WeaponModel enemyRifle = WeaponModel(
    length: 30,
    gripAt: 0.3,
    foreAt: 0.63,
    magAt: 0.42,
    magLength: 8,
    thickness: 3.2,
    scope: false,
    pump: false,
    metal: Color(0xFF2B2A28),
    furniture: Color(0xFF5E3E26),
  );

  static const WeaponModel heavyGun = WeaponModel(
    length: 38,
    gripAt: 0.3,
    foreAt: 0.6,
    magAt: 0.38,
    magLength: 6,
    thickness: 4.6,
    scope: false,
    pump: false,
    metal: Color(0xFF26262A),
    furniture: Color(0xFF3A3C40),
  );

  static const WeaponModel minigun = WeaponModel(
    length: 40,
    gripAt: 0.25,
    foreAt: 0.5,
    magAt: 0.3,
    magLength: 9,
    thickness: 6.4,
    scope: false,
    pump: false,
    metal: Color(0xFF1E1E22),
    furniture: Color(0xFF5A1E18),
  );
}
