import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_profile.dart';
import '../models/match_data.dart';

class DatabaseController extends GetxController {
  static DatabaseController instance = Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxList<UserProfile> leaderboard = <UserProfile>[].obs;
  RxList<MatchData> matchHistory = <MatchData>[].obs;
  RxMap<String, dynamic> gameConfig = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
    fetchConfig();
  }

  void fetchLeaderboard() {
    _db.collection('users')
        .orderBy('winCount', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      leaderboard.value = snapshot.docs.map((doc) => 
          UserProfile.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> fetchMatchHistory(String userId) async {
    QuerySnapshot snapshot = await _db.collection('matches')
        .where('playerId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    
    matchHistory.value = snapshot.docs.map((doc) => 
        MatchData(
          matchId: doc.id,
          playerId: doc['playerId'],
          characterUsed: doc['characterUsed'],
          outcome: doc['outcome'],
          totalHits: doc['totalHits'],
          totalAttempts: doc['totalAttempts'],
          xpEarned: doc['xpEarned'],
          creditsEarned: doc['creditsEarned'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
        )).toList();
  }

  void fetchConfig() {
    _db.collection('config').doc('combat_balance').snapshots().listen((doc) {
      if (doc.exists) {
        gameConfig.value = doc.data()!;
      } else {
        // Default values if not set
        gameConfig.value = {
          'maxHealth': 100.0,
          'strengthMultiplier': 1.0,
          'staminaCost': 10.0,
          'rewardMultiplier': 1.0,
        };
      }
    });
  }

  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    await _db.collection('config').doc('combat_balance').set(newConfig, SetOptions(merge: true));
  }
}
