import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/character_stats.dart';
import '../controllers/game_controller.dart';
import 'combat_screen.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SELECT YOUR FIGHTER')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'CHOOSE YOUR ARCHETYPE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: CharacterStats.archetypes.length,
              itemBuilder: (context, index) {
                final character = CharacterStats.archetypes[index];
                return Obx(() {
                  bool isSelected = GameController.instance.selectedCharacter.value == character;
                  return GestureDetector(
                    onTap: () => GameController.instance.selectCharacter(character),
                    child: Card(
                      color: isSelected ? Colors.red[800] : Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              index == 0 ? Icons.bolt : index == 1 ? Icons.fitness_center : Icons.shield,
                              size: 50,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(character.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(character.description, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  _buildStatRow('Health', character.health, Colors.green),
                                  _buildStatRow('Stamina', character.stamina, Colors.blue),
                                  _buildStatRow('Strength', character.strength, Colors.orange),
                                  _buildStatRow('Speed', character.speed, Colors.purple),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  GameController.instance.startMatch();
                  Get.to(() => const CombatScreen());
                },
                child: const Text('ENTER ARENA', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 150, // Normalized for visual
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
