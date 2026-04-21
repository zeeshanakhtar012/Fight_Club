import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/database_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  static Future<void> processMatchEnd() async {
    final auth = AuthController.instance;
    final game = GameController.instance;
    
    if (auth.profile == null) return;

    double accuracy = game.totalAttempts.value > 0 
        ? game.totalHits.value / game.totalAttempts.value 
        : 0.0;

    int xpEarned = (100 * accuracy).toInt();
    int baseCredits = game.matchResult.value == "win" ? 100 : 50;
    int creditsEarned = (baseCredits * (1 + accuracy)).toInt();

    // Update Local Profile
    int newXp = auth.profile!.experiencePoints + xpEarned;
    int newLevel = (newXp / 500).floor() + 1;
    int newCredits = auth.profile!.fightCredits + creditsEarned;
    int newWins = auth.profile!.winCount + (game.matchResult.value == "win" ? 1 : 0);
    int newLosses = auth.profile!.lossCount + (game.matchResult.value == "win" ? 0 : 1);

    // Sync to Firestore (Ideal: Call Cloud Function)
    // For prototype, we update Firestore directly but mention it in documentation
    await FirebaseFirestore.instance.collection('users').doc(auth.profile!.userId).update({
      'experiencePoints': newXp,
      'level': newLevel,
      'fightCredits': newCredits,
      'winCount': newWins,
      'lossCount': newLosses,
      'lastLogin': FieldValue.serverTimestamp(),
    });

    // Add to Match History
    await FirebaseFirestore.instance.collection('matches').add({
      'playerId': auth.profile!.userId,
      'characterUsed': game.selectedCharacter.value.name,
      'outcome': game.matchResult.value,
      'totalHits': game.totalHits.value,
      'totalAttempts': game.totalAttempts.value,
      'xpEarned': xpEarned,
      'creditsEarned': creditsEarned,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
