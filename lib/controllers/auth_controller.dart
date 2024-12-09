import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userController = UserController();

  Future<UserModel?> signUp(String email, String password, String name,
      String phoneNumber, File? _profileImage) async {
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
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          preferences: ['Books', 'Gadgets', 'Clothing'],
        );
        await _userController.saveUser(userModel);

        if (_profileImage != null) {
          await _userController.updateProfilePic(userModel.id, _profileImage);
        }
        // if (_profileImage != null) {
        //   final profileImageUrl = await _uploadProfileImage(userModel.id);
        // }

        return userModel;
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
    return null;
  }

  // // Update the user profile in Firestore
  // await _authController.updateUserProfile(userModel.id, {
  //   'profilePic': profileImageUrl,
  // });
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