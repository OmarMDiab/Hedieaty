import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String id;
  final String pfp;
  final String name;
  final String email;
  final String phoneNumber;
  final List<String> preferences;

  // Default constructor with optional parameters
  UserModel({
    this.id = '',
    this.pfp = '',
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.preferences = const [],
  });

  Future<void> saveUser({
    required String id,
    required String pfp,
    required String name,
    required String email,
    required phoneNumber,
    required List<String> preferences,
  }) async {
    try {
      await _firestore.collection('users').doc(id).set({
        'id': id,
        'pfp': pfp,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  Future<UserModel?> fetchUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        //return doc.data();
        var data = doc.data();
        return UserModel(
          id: id,
          pfp: data?['pfp'],
          name: data?['name'],
          email: data?['email'],
          phoneNumber: data?['phoneNumber'],
          preferences: List<String>.from(data?['preferences']),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<void> addFriend({
    required String userID,
    required String friendID,
  }) async {
    try {
      await _firestore.collection('friends').doc(userID).update({
        'friends': FieldValue.arrayUnion([friendID]),
      });
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        await _firestore.collection('friends').doc(userID).set({
          'friends': [friendID],
        });
      } else {
        throw Exception('Error adding Friend: $e');
      }
    }
  }
}
