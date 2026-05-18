import 'package:get/get.dart';
import '../models/character_stats.dart';

class GameController extends GetxController {
  static GameController instance = Get.find();

  var selectedCharacter = CharacterStats.archetypes[0].obs;
  
  var currentHealth = 100.0.obs;
  var currentStamina = 100.0.obs;
  var opponentHealth = 100.0.obs;
  
  var totalHits = 0.obs;
  var totalAttempts = 0.obs;
  
  var isMatchOver = false.obs;
  var matchResult = "".obs;

  void selectCharacter(CharacterStats stats) {
    selectedCharacter.value = stats;
  }

  void startMatch() {
    currentHealth.value = selectedCharacter.value.health;
    currentStamina.value = selectedCharacter.value.stamina;
    opponentHealth.value = 100.0;
    totalHits.value = 0;
    totalAttempts.value = 0;
    isMatchOver.value = false;
    matchResult.value = "";
  }

  void updateStats({double? playerHealth, double? playerStamina, double? opponentHealthVal, bool? hit, bool? attempt}) {
    if (playerHealth != null) currentHealth.value = playerHealth;
    if (playerStamina != null) currentStamina.value = playerStamina;
    if (opponentHealthVal != null) opponentHealth.value = opponentHealthVal;
    if (hit == true) totalHits.value++;
    if (attempt == true) totalAttempts.value++;

    if (currentHealth.value <= 0) {
      endMatch("loss");
    } else if (opponentHealth.value <= 0) {
      endMatch("win");
    }
  }

  void endMatch(String result) {
    isMatchOver.value = true;
    matchResult.value = result;
    Get.offNamed('/result');
  }
}
