import '../models/user_model.dart';

// ProjectID: hedieaty-dc62b

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
        deviceToken: user.deviceToken,
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
  Future<String?> addFriend(String id, String phoneNumber) async {
    try {
      final friendToken =
          await _userModel.addFriend(userID: id, phoneNumber: phoneNumber);
      return friendToken;
    } catch (e) {
      return null;
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

  // update FCM Token
  Future<void> updateUserDeviceToken(String id, String? deviceToken) async {
    try {
      await _userModel.updateFCMToken(id, deviceToken);
    } catch (e) {
      throw Exception('Error updating FCM Token: $e');
    }
  }
}
