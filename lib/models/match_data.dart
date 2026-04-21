class MatchData {
  final String matchId;
  final String playerId;
  final String characterUsed;
  final String outcome; // 'win' or 'loss'
  final int totalHits;
  final int totalAttempts;
  final int xpEarned;
  final int creditsEarned;
  final DateTime timestamp;

  MatchData({
    required this.matchId,
    required this.playerId,
    required this.characterUsed,
    required this.outcome,
    required this.totalHits,
    required this.totalAttempts,
    required this.xpEarned,
    required this.creditsEarned,
    required this.timestamp,
  });

  double get accuracy => totalAttempts > 0 ? totalHits / totalAttempts : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'characterUsed': characterUsed,
      'outcome': outcome,
      'totalHits': totalHits,
      'totalAttempts': totalAttempts,
      'xpEarned': xpEarned,
      'creditsEarned': creditsEarned,
      'timestamp': timestamp,
    };
  }
}
