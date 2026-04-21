import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CREDIT SHOP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'YOUR BALANCE:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${AuthController.instance.profile?.fightCredits ?? 0} CREDITS',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildShopItem('Crimson Skin', 500, Icons.person_outline),
                  _buildShopItem('Neon Badge', 200, Icons.verified),
                  _buildShopItem('Strength Boost', 1000, Icons.bolt),
                  _buildShopItem('Stamina Elixir', 400, Icons.wine_bar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(String name, int price, IconData icon) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '$price Credits',
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                int current =
                    AuthController.instance.profile?.fightCredits ?? 0;
                if (current < price) {
                  Get.snackbar(
                    "Insufficient Funds",
                    "You need more Fight Credits!",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    "Success",
                    "You purchased $name!",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  // In a real app, deduct credits in Firestore here
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 30),
              ),
              child: const Text('BUY'),
            ),
          ],
        ),
      ),
    );
  }
}
