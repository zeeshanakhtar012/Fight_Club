import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../game/fight_club_game.dart';
import '../controllers/game_controller.dart';

class CombatScreen extends StatelessWidget {
  const CombatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = FightClubGame();

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // HUD - Health Bars
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHealthBar("PLAYER", Colors.green, true),
                _buildHealthBar("OPPONENT", Colors.red, false),
              ],
            ),
          ),

          // Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Directional Controls
                Row(
                  children: [
                    _buildControlButton(
                      Icons.arrow_back,
                      () => game.movePlayer(-1),
                      () => game.stopPlayer(),
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      Icons.arrow_forward,
                      () => game.movePlayer(1),
                      () => game.stopPlayer(),
                    ),
                  ],
                ),
                // Action Controls
                Row(
                  children: [
                    _buildControlButton(
                      Icons.shield,
                      () => game.playerBlock(true),
                      () => game.playerBlock(false),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    _buildControlButton(
                      Icons.sports_mma,
                      () => game.playerAttack(),
                      null,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Back Button / Exit
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBar(String label, Color color, bool isPlayer) {
    return Column(
      crossAxisAlignment: isPlayer
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Container(
          width: 150,
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Obx(() {
            double value = isPlayer
                ? GameController.instance.currentHealth.value
                : GameController.instance.opponentHealth.value;
            // Assuming max health 100 for normalization, but player can have more
            double percent =
                (value /
                        (isPlayer
                            ? GameController
                                  .instance
                                  .selectedCharacter
                                  .value
                                  .health
                            : 100.0))
                    .clamp(0.0, 1.0);
            return LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            );
          }),
        ),
        if (isPlayer) const SizedBox(height: 4),
        if (isPlayer)
          Obx(
            () => Text(
              'STAMINA: ${GameController.instance.currentStamina.value.toInt()}',
              style: const TextStyle(fontSize: 10, color: Colors.blue),
            ),
          ),
      ],
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressDown,
    VoidCallback? onPressUp, {
    Color color = Colors.grey,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressDown(),
      onTapUp: (_) => onPressUp?.call(),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
