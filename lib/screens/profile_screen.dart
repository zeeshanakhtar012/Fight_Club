import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var profile = AuthController.instance.profile;
    if (profile == null)
      return const Scaffold(body: Center(child: Text("Not Logged In")));

    // Calculate badges
    List<String> badges = [];
    if (profile.winCount >= 1) badges.add("First Win");
    if (profile.winCount >= 10) badges.add("10 Wins");
    // Placeholder for Perfect Match (requires specific match logic)

    return Scaffold(
      appBar: AppBar(title: const Text('PLAYER PROFILE')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                profile.username,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                profile.email,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Level & XP
              _buildProgressSection(
                "LEVEL ${profile.level}",
                profile.experiencePoints % 500 / 500,
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    "WINS",
                    profile.winCount.toString(),
                    Colors.green,
                  ),
                  _buildStatColumn(
                    "LOSSES",
                    profile.lossCount.toString(),
                    Colors.red,
                  ),
                  _buildStatColumn(
                    "CREDITS",
                    profile.fightCredits.toString(),
                    Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ACHIEVEMENTS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              badges.isEmpty
                  ? const Text("No badges earned yet. Keep fighting!")
                  : Wrap(
                      spacing: 10,
                      children: badges
                          .map(
                            (b) => Chip(
                              label: Text(b),
                              backgroundColor: Colors.red[900],
                              avatar: const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${(progress * 100).toInt()}%"),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
