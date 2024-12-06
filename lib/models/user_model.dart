import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final String id;
  final String name;
  final String email;
  final List<String> preferences;

  // Default constructor with optional parameters
  UserModel(
      {
    this.id = '',
    this.name = '',
    this.email = '',
    this.preferences = const [],
  }
  );


  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required List<String> preferences,
  }) async {
    try {
      await _firestore.collection('users').doc(id).set({
        'id': id,
        'name': name,
        'email': email,
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }
}
