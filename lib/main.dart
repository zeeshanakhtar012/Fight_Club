import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/auth_controller.dart';
import 'controllers/database_controller.dart';
import 'controllers/game_controller.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/character_selection_screen.dart';
import 'screens/match_result_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: User will connect Firebase manually.
  // We initialize with default options if available or just wrap in try-catch for now.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase initialization error (expected if not yet configured): $e");
  }

  // Initialize Controllers
  Get.put(AuthController());
  Get.put(DatabaseController());
  Get.put(GameController());

  runApp(const FightClubApp());
}

class FightClubApp extends StatelessWidget {
  const FightClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fight Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
          surface: Colors.grey[900]!,
        ),
        textTheme: GoogleFonts.russoOneTextTheme(
          ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.red,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const AuthScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
          name: '/select-character',
          page: () => const CharacterSelectionScreen(),
        ),
        GetPage(name: '/result', page: () => const MatchResultScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/leaderboard', page: () => const LeaderboardScreen()),
        GetPage(name: '/shop', page: () => const ShopScreen()),
        GetPage(name: '/admin', page: () => const AdminDashboardScreen()),
      ],
    );
  }
}
