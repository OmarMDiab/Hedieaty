import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userController = UserController();

  Future<UserModel?> signUp(String email, String password, String name,
      String phoneNumber, String profileImage, List<String> preferences) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      // Save user data to Firestore using the user controller
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          pfp: profileImage,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          preferences: preferences,
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
        return await _userController.fetchUser(user.uid);
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
