import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/reward_service.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({super.key});

  @override
  _MatchResultScreenState createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  bool isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processRewards();
  }

  _processRewards() async {
    await RewardService.processMatchEnd();
    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final game = GameController.instance;
    bool isWin = game.matchResult.value == "win";

    return Scaffold(
      body: Center(
        child: isProcessing
            ? const CircularProgressIndicator(color: Colors.red)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isWin ? 'VICTORY' : 'DEFEATED',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isWin ? Colors.green : Colors.red,
                      letterSpacing: 10,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildStatText('HITS', '${game.totalHits.value}'),
                  _buildStatText('ATTEMPTS', '${game.totalAttempts.value}'),
                  _buildStatText(
                    'ACCURACY',
                    '${(game.totalAttempts.value > 0 ? (game.totalHits.value / game.totalAttempts.value * 100) : 0).toInt()}%',
                  ),
                  const Divider(
                    color: Colors.white24,
                    indent: 50,
                    endIndent: 50,
                    height: 40,
                  ),
                  _buildStatText(
                    'XP EARNED',
                    '+${(100 * (game.totalAttempts.value > 0 ? game.totalHits.value / game.totalAttempts.value : 0)).toInt()}',
                    color: Colors.blue,
                  ),
                  _buildStatText(
                    'CREDITS',
                    '+${(isWin ? 100 : 50) * (1 + (game.totalAttempts.value > 0 ? game.totalHits.value / game.totalAttempts.value : 0)).toInt()}',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.offAllNamed('/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                        child: const Text('HOME'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => Get.offNamed('/select-character'),
                        child: const Text('REMATCH'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatText(
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
