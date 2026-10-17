import 'package:flutter/material.dart';

/// Six elements in a ring: each one beats the next.
/// Tide > Inferno > Frost > Shadow > Terra > Storm > Tide
enum BeastElement {
  tide('Tide', '🌊', Color(0xFF2FA8FF), Color(0xFF0B3E8A), 'Tidal Crash'),
  inferno('Inferno', '🔥', Color(0xFFFF6A1F), Color(0xFF8A1A06), 'Magma Burst'),
  frost('Frost', '❄️', Color(0xFF8EE8FF), Color(0xFF2B5C8C), 'Glacier Fang'),
  shadow('Shadow', '🌑', Color(0xFFB15CFF), Color(0xFF2A0F4F), 'Void Bite'),
  terra('Terra', '🪨', Color(0xFFC9A24A), Color(0xFF4F3A12), 'Quake Slam'),
  storm('Storm', '⚡', Color(0xFFFFE14D), Color(0xFF6B5A00), 'Thunder Howl');

  const BeastElement(this.label, this.emoji, this.color, this.deep, this.specialMove);
  final String label;
  final String emoji;
  final Color color;
  final Color deep;
  final String specialMove;

  BeastElement get beats => BeastElement.values[(index + 1) % BeastElement.values.length];
  BeastElement get weakTo => BeastElement.values[(index - 1 + BeastElement.values.length) % BeastElement.values.length];

  /// Damage multiplier when [this] attacks [defender].
  double against(BeastElement defender) {
    if (defender == beats) return 1.5;
    if (defender == weakTo) return 0.7;
    return 1.0;
  }

  String get roarHint => switch (this) {
    BeastElement.tide => 'smooth, mid-range roar',
    BeastElement.inferno => 'loud, raspy roar',
    BeastElement.frost => 'high, clean roar',
    BeastElement.shadow => 'quiet, eerie whisper',
    BeastElement.terra => 'deep, steady roar',
    BeastElement.storm => 'high, wild, shifting roar',
  };
}

enum Rarity {
  common('Common', Color(0xFFB8B3D1)),
  rare('Rare', Color(0xFF38B6FF)),
  epic('Epic', Color(0xFFC05CFF)),
  legendary('Legendary', Color(0xFFFFC93C));

  const Rarity(this.label, this.color);
  final String label;
  final Color color;
}
