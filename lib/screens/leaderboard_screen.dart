import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/database_controller.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GLOBAL RANKINGS')),
      body: Obx(() {
        var players = DatabaseController.instance.leaderboard;
        if (players.isEmpty) {
          return const Center(child: Text("No data found or loading..."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final player = players[index];
            bool isTop3 = index < 3;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isTop3 ? Colors.amber : Colors.red[900],
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                player.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Level ${player.level}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${player.winCount} WINS',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${player.experiencePoints} XP',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
