import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/services/sqlite_helper.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userController = UserController();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<UserModel?> signUp(String email, String password, String name,
      String phoneNumber, String profileImage, List<String> preferences) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      final String? deviceToken = await messaging.getToken();

      // Save user data to Firestore using the user controller
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          pfp: profileImage,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          preferences: preferences,
          deviceToken: deviceToken,
        );
        await _userController.saveUser(userModel);

        return userModel;
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final String? deviceToken = await messaging.getToken();
        await _userController.updateUserDeviceToken(
            user.uid, deviceToken); // Update device token
        await SQLiteHelper().syncDataAfterLogin(user.uid);
        return await _userController.fetchUser(user.uid);
        // Fetch user data
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
    return null;
  }

  // get current user id
  String? getCurrentUserID() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> logout() async => await _auth.signOut();
}
