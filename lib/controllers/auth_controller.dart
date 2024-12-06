import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userController = UserController();

  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          name: name,
          email: email,
          preferences: ['Books', 'Gadgets', 'Clothing'],
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

  Future<void> logout() async => await _auth.signOut();
}
