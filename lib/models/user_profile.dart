class UserProfile {
  final String userId;
  final String username;
  final String email;
  final int level;
  final int experiencePoints;
  final int winCount;
  final int lossCount;
  final int fightCredits;
  final DateTime? lastLogin;
  final List<String> unlockedItems;
  final bool isAdmin;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.level = 1,
    this.experiencePoints = 0,
    this.winCount = 0,
    this.lossCount = 0,
    this.fightCredits = 0,
    this.lastLogin,
    this.unlockedItems = const [],
    this.isAdmin = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String id) {
    return UserProfile(
      userId: id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      level: data['level'] ?? 1,
      experiencePoints: data['experiencePoints'] ?? 0,
      winCount: data['winCount'] ?? 0,
      lossCount: data['lossCount'] ?? 0,
      fightCredits: data['fightCredits'] ?? 0,
      lastLogin: data['lastLogin'] != null ? (data['lastLogin'] as dynamic).toDate() : null,
      unlockedItems: List<String>.from(data['unlockedItems'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'level': level,
      'experiencePoints': experiencePoints,
      'winCount': winCount,
      'lossCount': lossCount,
      'fightCredits': fightCredits,
      'lastLogin': lastLogin,
      'unlockedItems': unlockedItems,
      'isAdmin': isAdmin,
    };
  }
}
