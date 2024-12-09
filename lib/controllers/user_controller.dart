import '../models/user_model.dart';
import 'dart:io';

class UserController {
  final UserModel _userModel = UserModel();

  Future<void> saveUser(UserModel user) async {
    try {
      await _userModel.saveUser(
        id: user.id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        preferences: user.preferences,
      );
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  Future<UserModel?> fetchUser(String id) async {
    try {
      final user = await _userModel.fetchUser(id);
      if (user != null) {
        return user;
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
    return null;
  }

  Future<void> deleteAccount(UserModel user, String Pass) async {
    try {
      await _userModel.deleteUser(user.id, user.email, Pass);
    } catch (e) {
      throw Exception('Error deleting Account: $e');
    }
  }

  // update user profilePic
  Future<void> updateProfilePic(String id, File? profilePic) async {
    try {
      await _userModel.updateProfilePic(id, profilePic);
    } catch (e) {
      throw Exception('Error updating profile pic: $e');
    }
  }
}
