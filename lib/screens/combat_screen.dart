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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Movement Cluster
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(Icons.keyboard_double_arrow_up, () => game.jumpPlayer(), null, color: Colors.greenAccent),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildControlButton(Icons.chevron_left, () => game.movePlayer(-1), () => game.stopPlayer()),
                        const SizedBox(width: 15),
                        _buildControlButton(Icons.chevron_right, () => game.movePlayer(1), () => game.stopPlayer()),
                      ],
                    ),
                  ],
                ),
                // Action Cluster
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _buildControlButton(Icons.shield_outlined, () => game.playerBlock(true), () => game.playerBlock(false), color: Colors.blueAccent),
                        const SizedBox(width: 15),
                        _buildControlButton(Icons.front_hand, () => game.playerAttack(), null, color: Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildControlButton(Icons.kitesurfing, () => game.playerKick(), null, color: Colors.orangeAccent),
                  ],
                ),
              ],
            ),
          ),

          // Back Button / Exit
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        Container(
          width: 160,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black38,
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, spreadRadius: 1),
            ],
          ),
          child: Obx(() {
            double value = isPlayer
                ? GameController.instance.currentHealth.value
                : GameController.instance.opponentHealth.value;
            double maxH = isPlayer
                ? GameController.instance.selectedCharacter.value.health
                : 100.0;
            double percent = (value / maxH).clamp(0.0, 1.0);
            return Stack(
              children: [
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                if (percent > 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        if (isPlayer) const SizedBox(height: 4),
        if (isPlayer)
          Obx(
            () => Container(
            width: 160,
            alignment: Alignment.centerLeft,
            child: Text(
              'ENERGY: ${GameController.instance.currentStamina.value.toInt()}%', 
              style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)
            ),
          )),
      ],
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressDown,
    VoidCallback? onPressUp, {
    Color color = Colors.white,
  }) {
    return _ControlItem(icon: icon, color: color, onPressDown: onPressDown, onPressUp: onPressUp);
  }
}

class _ControlItem extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressDown;
  final VoidCallback? onPressUp;

  const _ControlItem({required this.icon, required this.color, required this.onPressDown, this.onPressUp});

  @override
  State<_ControlItem> createState() => _ControlItemState();
}

class _ControlItemState extends State<_ControlItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        widget.onPressDown();
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressUp?.call();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
        widget.onPressUp?.call();
      },
      child: AnimatedScale(
        scale: isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isPressed ? widget.color.withOpacity(0.4) : Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: isPressed ? Colors.white : widget.color.withOpacity(0.6), width: 2),
            boxShadow: [
              if (isPressed)
                BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
