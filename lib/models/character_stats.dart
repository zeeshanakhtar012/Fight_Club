class CharacterStats {
  final String name;
  final double health;
  final double stamina;
  final double strength;
  final double speed;
  final String description;

  CharacterStats({
    required this.name,
    required this.health,
    required this.stamina,
    required this.strength,
    required this.speed,
    required this.description,
  });

  static List<CharacterStats> archetypes = [
    CharacterStats(
      name: 'Speed Fighter',
      health: 80,
      stamina: 120,
      strength: 15,
      speed: 25,
      description: 'Fast and agile, but fragile.',
    ),
    CharacterStats(
      name: 'Strength Fighter',
      health: 100,
      stamina: 100,
      strength: 25,
      speed: 15,
      description: 'Balanced power and endurance.',
    ),
    CharacterStats(
      name: 'Tank Fighter',
      health: 150,
      stamina: 80,
      strength: 10,
      speed: 10,
      description: 'Huge health pool, but slow.',
    ),
  ];
}
