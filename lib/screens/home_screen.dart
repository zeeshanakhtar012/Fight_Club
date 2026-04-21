import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var profile = AuthController.instance.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MAIN MENU'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthController.instance.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Stats Card
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.username ?? 'GUEST',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Level ${profile?.level ?? 1}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Credits: ${profile?.fightCredits ?? 0}',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    'PLAY',
                    Icons.sports_martial_arts,
                    () => Get.toNamed('/select-character'),
                  ),
                  _buildMenuCard(
                    'LEADERBOARD',
                    Icons.leaderboard,
                    () => Get.toNamed('/leaderboard'),
                  ),
                  _buildMenuCard(
                    'PROFILE',
                    Icons.account_circle,
                    () => Get.toNamed('/profile'),
                  ),
                  _buildMenuCard(
                    'SHOP',
                    Icons.shopping_cart,
                    () => Get.toNamed('/shop'),
                  ),
                  if (profile?.isAdmin ?? false)
                    _buildMenuCard(
                      'ADMIN',
                      Icons.admin_panel_settings,
                      () => Get.toNamed('/admin'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.red[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
