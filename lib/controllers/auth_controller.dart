import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_profile.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rxn<User> _firebaseUser = Rxn<User>();
  Rxn<UserProfile> _userProfile = Rxn<UserProfile>();

  User? get user => _firebaseUser.value;
  UserProfile? get profile => _userProfile.value;

  @override
  void onReady() {
    super.onReady();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    // Add a slight delay to allow Splash Screen to be visible
    await Future.delayed(const Duration(seconds: 2));
    
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      await _fetchUserProfile(user.uid);
      Get.offAllNamed('/home');
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userProfile.value = UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not fetch user profile: $e");
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      UserProfile newProfile = UserProfile(
        userId: credential.user!.uid,
        username: username,
        email: email,
        lastLogin: DateTime.now(),
      );

      await _db.collection('users').doc(newProfile.userId).set(newProfile.toMap());
      _userProfile.value = newProfile;
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
