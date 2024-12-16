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

  // update user
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _userModel.updateUser(
        id: user.id,
        pfp: user.pfp,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        preferences: user.preferences,
      );
      //return fetchUser(user.id);
    } catch (e) {
      throw Exception('Error updating user: $e');
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

  // add friends
  Future<bool> addFriend(String id, String phoneNumber) async {
    try {
      final status =
          await _userModel.addFriend(userID: id, phoneNumber: phoneNumber);
      return status;
    } catch (e) {
      return false;
    }
  }

  // fetch all user friends
  Future<List<UserModel>> getFriends(String id) async {
    try {
      final friends = await _userModel.fetchUserFriends(id);
      return friends;
    } catch (e) {
      throw Exception('Error fetching user friends: $e');
    }
  }
}
