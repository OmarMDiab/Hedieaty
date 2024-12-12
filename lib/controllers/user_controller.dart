import '../models/user_model.dart';

class UserController {
  final UserModel _userModel = UserModel();

  Future<void> saveUser(UserModel user) async {
    try {
      await _userModel.saveUser(
        id: user.id,
        pfp: user.pfp,
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
}
