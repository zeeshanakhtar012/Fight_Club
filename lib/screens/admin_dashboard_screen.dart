import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/database_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final healthController = TextEditingController();
  final strengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    healthController.text = DatabaseController.instance.gameConfig['maxHealth']?.toString() ?? "100";
    strengthController.text = DatabaseController.instance.gameConfig['strengthMultiplier']?.toString() ?? "1.0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADMIN DASHBOARD')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('COMBAT BALANCE PARAMETERS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 24),
            TextField(
              controller: healthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Global Max Health', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: strengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Damage Multiplier (e.g. 1.2)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await DatabaseController.instance.updateConfig({
                    'maxHealth': double.tryParse(healthController.text) ?? 100.0,
                    'strengthMultiplier': double.tryParse(strengthController.text) ?? 1.0,
                  });
                  Get.snackbar("Success", "Combat parameters updated!", backgroundColor: Colors.green);
                },
                child: const Text('SAVE CHANGES'),
              ),
            ),
            const Spacer(),
            const Text('Note: These changes affect all new matches started by any player.', style: TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
