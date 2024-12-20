import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/services/sqlite_helper.dart';
import 'dart:convert';

class UserModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final sqliteHelper = SQLiteHelper();
  final String id;
  final String pfp;
  final String name;
  final String email;
  final String phoneNumber;
  final int numberOfEvents;
  final List<String> friends;
  final List<String> preferences;
  final String? deviceToken;

  // Default constructor with optional parameters
  UserModel({
    this.id = '',
    this.pfp = '',
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.friends = const [],
    this.numberOfEvents = 0,
    this.preferences = const [],
    this.deviceToken = '',
  });

  Future<void> saveUser({
    required String id,
    required String pfp,
    required String name,
    required String email,
    required phoneNumber,
    List<String>? preferences,
    String? deviceToken,
  }) async {
    try {
      String? preferencesJson =
          preferences != null ? jsonEncode(preferences) : null;

      await sqliteHelper.insertUser(
          id, name, pfp, email, phoneNumber, preferencesJson, deviceToken);

      await _firestore.collection('users').doc(id).set({
        'id': id,
        'pfp': pfp,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'friends': [],
        'preferences': preferences,
        'deviceToken': deviceToken,
      });
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  // update user
  Future<void> updateUser({
    required String id,
    String? pfp,
    String? name,
    String? email,
    String? phoneNumber,
    List<String>? preferences,
    String? deviceToken,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (pfp != null) updateData['pfp'] = pfp;
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (preferences != null) updateData['preferences'] = preferences;
      if (deviceToken != null) updateData['deviceToken'] = deviceToken;

      var preferencesJson =
          preferences != null ? jsonEncode(preferences) : null;

      await sqliteHelper.updateUser(
          id, name, pfp, email, phoneNumber, preferencesJson, deviceToken);

      await _firestore.collection('users').doc(id).update(updateData);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? pfp,
    //preferences
    List<String>? preferences,
  }) {
    return UserModel(
      id: id, // Keep ID the same as it's usually immutable
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pfp: pfp ?? this.pfp,
      preferences: preferences ?? this.preferences,
    );
  }

  Future<UserModel?> fetchUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();

      if (doc.exists) {
        // for friends cards
        final eventdocs = await _firestore
            .collection('events')
            .where('userID', isEqualTo: id)
            .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .get();

        final numberOfEvents = eventdocs.docs.length; // get numeber of events
        var userData = doc.data();
        return UserModel(
          id: id,
          pfp: userData?['pfp'],
          name: userData?['name'],
          email: userData?['email'],
          phoneNumber: userData?['phoneNumber'],
          numberOfEvents: numberOfEvents,
          friends: List<String>.from(userData?['friends'] ?? []),
          preferences: List<String>.from(userData?['preferences'] ?? []),
          deviceToken: userData?['deviceToken'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<String?> addFriend({
    required String userID,
    required String phoneNumber,
  }) async {
    String? friendID;
    try {
      // Fetch the user with the given phone number
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      // >>> phone numbers are unique and we get only one document
      friendID = querySnapshot.docs.first.id;

      final userDocRef = _firestore.collection('users').doc(userID);
      final friendDocRef = _firestore.collection('users').doc(friendID);

      final userDoc = await userDocRef.get();
      final friendDoc = await friendDocRef.get();

      if (userDoc.exists) {
        await userDocRef.update({
          'friends': FieldValue.arrayUnion([friendID]),
        });
      } else {
        await userDocRef.set({
          'friends': [friendID],
        });
      }

      if (friendDoc.exists) {
        await friendDocRef.update({
          'friends': FieldValue.arrayUnion([userID]),
        });
      } else {
        await friendDocRef.set({
          'friends': [userID],
        });
      }
      final String? friendDeviceToken = friendDoc.data()?['deviceToken'];

      return friendDeviceToken;
    } catch (e) {
      throw Exception('Error adding Friend: $e');
    }
  }

  Future<List<UserModel>> fetchUserFriends(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        var data = doc.data();
        final friends = List<String>.from(data?['friends'] ?? []);
        List<UserModel> userFriends = [];
        for (var friendID in friends) {
          final friend = await fetchUser(friendID);
          if (friend != null) {
            userFriends.add(friend);
          }
        }
        return userFriends;
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching user friends: $e');
    }
  }

  // update user device token
  Future<void> updateFCMToken(String id, String? deviceToken) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'deviceToken': deviceToken,
      });
    } catch (e) {
      throw Exception('Error updating user device token: $e');
    }
  }
}
