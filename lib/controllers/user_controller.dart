import '../models/user_model.dart';

class UserController {
  final UserModel _userModel = UserModel();

  Future<void> saveUser(UserModel user) async {
    try {
      await _userModel.saveUser(
        id: user.id,
        name: user.name,
        email: user.email,
        preferences: user.preferences,
      );
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  Future<UserModel?> fetchUser(String id) async {
    try {
      final data = await _userModel.fetchUser(id);
      if (data != null) {
        return UserModel(
          id: id,
          name: data['name'],
          email: data['email'],
          preferences: List<String>.from(data['preferences']),
        );
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
    return null;
  }
}
