import 'dart:ui';

enum DragonElement { fire, water, shadow, nature, solar }

enum HornStyle { curved, crystal, sharp, leafy, crown }

/// Static definition of a playable dragon: identity, palette and stats.
class DragonDef {
  const DragonDef({
    required this.id,
    required this.name,
    required this.element,
    required this.elementLabel,
    required this.attackName,
    required this.specialName,
    required this.specialDescription,
    required this.personality,
    required this.body,
    required this.bodyDark,
    required this.belly,
    required this.wing,
    required this.wingDark,
    required this.horn,
    required this.eye,
    required this.accent,
    required this.glow,
    required this.hornStyle,
    this.attackDamage = 1,
    this.specialCooldown = 14,
    this.flightCapacity = 1.0,
  });

  final String id;
  final String name;
  final DragonElement element;
  final String elementLabel;
  final String attackName;
  final String specialName;
  final String specialDescription;
  final String personality;

  final Color body;
  final Color bodyDark;
  final Color belly;
  final Color wing;
  final Color wingDark;
  final Color horn;
  final Color eye;
  final Color accent;
  final Color glow;
  final HornStyle hornStyle;

  /// Damage dealt by one basic attack projectile.
  final int attackDamage;

  /// Special ability cooldown in seconds.
  final double specialCooldown;

  /// Multiplier on flight energy capacity.
  final double flightCapacity;
}

class Dragons {
  Dragons._();

  static const ember = DragonDef(
    id: 'ember',
    name: 'Ember',
    element: DragonElement.fire,
    elementLabel: 'Fire',
    attackName: 'Fire Breath',
    specialName: 'Fire Burst',
    specialDescription: 'Unleashes a roaring wave of fire that scorches every enemy and obstacle ahead.',
    personality: 'A small, friendly dragon who never backs down from an adventure.',
    body: Color(0xFFFF8A2A),
    bodyDark: Color(0xFFD9481E),
    belly: Color(0xFFFFD36B),
    wing: Color(0xFFFF6A3D),
    wingDark: Color(0xFFC53A22),
    horn: Color(0xFFFFE6A0),
    eye: Color(0xFF3B2A1A),
    accent: Color(0xFFFFC23D),
    glow: Color(0xFFFFB347),
    hornStyle: HornStyle.curved,
    specialCooldown: 14,
  );

  static const aqua = DragonDef(
    id: 'aqua',
    name: 'Aqua',
    element: DragonElement.water,
    elementLabel: 'Water',
    attackName: 'Water Blast',
    specialName: 'Water Shield',
    specialDescription: 'A bubble of water makes Aqua invulnerable for 4 seconds and pulls in nearby coins.',
    personality: 'Calm and curious, Aqua loves splashing through waterfalls.',
    body: Color(0xFF2F9BFF),
    bodyDark: Color(0xFF1F5FCC),
    belly: Color(0xFF8DF3FF),
    wing: Color(0xFF39C6E8),
    wingDark: Color(0xFF1B7FB8),
    horn: Color(0xFFBFF7FF),
    eye: Color(0xFF14305A),
    accent: Color(0xFF6FF2FF),
    glow: Color(0xFF7FE7FF),
    hornStyle: HornStyle.crystal,
    specialCooldown: 15,
  );

  static const shadow = DragonDef(
    id: 'shadow',
    name: 'Shadow',
    element: DragonElement.shadow,
    elementLabel: 'Shadow Magic',
    attackName: 'Shadow Wave',
    specialName: 'Shadow Dash',
    specialDescription: 'Dashes forward as pure shadow, passing through hazards and striking every enemy in the way.',
    personality: 'Mysterious and quick, Shadow moves like a whisper at dusk.',
    body: Color(0xFF8A4FE0),
    bodyDark: Color(0xFF4E2A96),
    belly: Color(0xFFC9A6FF),
    wing: Color(0xFF3D2470),
    wingDark: Color(0xFF231443),
    horn: Color(0xFFE2D2FF),
    eye: Color(0xFFFF5CE1),
    accent: Color(0xFFE47BFF),
    glow: Color(0xFFD27BFF),
    hornStyle: HornStyle.sharp,
    specialCooldown: 11,
  );

  static const leaf = DragonDef(
    id: 'leaf',
    name: 'Leaf',
    element: DragonElement.nature,
    elementLabel: 'Nature',
    attackName: 'Leaf Storm',
    specialName: 'Nature Shield',
    specialDescription: 'Grows a thorny vine shield that blocks the next 2 hits and damages enemies that touch it.',
    personality: 'Gentle guardian of the magical forests, Leaf befriends every creature.',
    body: Color(0xFF4CCB55),
    bodyDark: Color(0xFF268A3C),
    belly: Color(0xFFFFE27A),
    wing: Color(0xFF7FE06A),
    wingDark: Color(0xFF3B9A44),
    horn: Color(0xFFFFCB3D),
    eye: Color(0xFF1E3A16),
    accent: Color(0xFFFFD84D),
    glow: Color(0xFFB9FF7A),
    hornStyle: HornStyle.leafy,
    specialCooldown: 16,
    flightCapacity: 1.15,
  );

  static const solar = DragonDef(
    id: 'solar',
    name: 'Solar',
    element: DragonElement.solar,
    elementLabel: 'Solar Magic',
    attackName: 'Sun Orb',
    specialName: 'Solar Blast',
    specialDescription: 'Channels the sun into a colossal beam that obliterates everything on screen ahead.',
    personality: 'Majestic and radiant, Solar is said to be born from the first sunrise.',
    body: Color(0xFFFFC21A),
    bodyDark: Color(0xFFE07A10),
    belly: Color(0xFFFFF2B0),
    wing: Color(0xFFFF9F1C),
    wingDark: Color(0xFFE0631A),
    horn: Color(0xFFFFFFFF),
    eye: Color(0xFFB2410E),
    accent: Color(0xFFFFF27A),
    glow: Color(0xFFFFE066),
    hornStyle: HornStyle.crown,
    attackDamage: 2,
    specialCooldown: 18,
    flightCapacity: 1.2,
  );

  static const List<DragonDef> all = [ember, aqua, shadow, leaf, solar];

  static DragonDef byId(String id) => all.firstWhere((d) => d.id == id, orElse: () => ember);
}
