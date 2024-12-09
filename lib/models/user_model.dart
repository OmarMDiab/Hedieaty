import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String id;
  final String profilePic;
  final String name;
  final String email;
  final String phoneNumber;
  final List<String> preferences;

  // Default constructor with optional parameters
  UserModel({
    this.id = '',
    this.profilePic = '',
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.preferences = const [],
  });

  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required phoneNumber,
    required List<String> preferences,
  }) async {
    try {
      await _firestore.collection('users').doc(id).set({
        'id': id,
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

  Future<void> deleteUser(String userId, String email, String password) async {
    try {
      // Delete user from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Reauthenticate the user before deletion
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete the user from Firebase Authentication
      await user.delete();
    } catch (e) {
      throw Exception('Error deleting user account: $e');
    }
  }

  // friend functions >>>>>>>>>>>>>>>>>>>>>>>>
  Future<UserModel?> searchByPhone(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phone)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        return UserModel(
          id: querySnapshot.docs.first.id,
          name: data['name'],
          email: data['email'],
          phoneNumber: data['phoneNumber'],
          preferences: List<String>.from(data['preferences']),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user by phone: $e');
    }
  }

  Future<void> addFriend({
    required String userID,
    required String friendID,
  }) async {
    try {
      await _firestore.collection('friends').doc(userID).set({
        'userID': userID,
        'friendID': friendID,
      });
    } catch (e) {
      throw Exception('Error adding Friend: $e');
    }
  }

  Future<void> updateProfilePic(String id, File? profileImage) async {
    try {
      if (profileImage == null) {
        throw Exception("No profile image selected");
      }

      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pics/$id.jpg');
      final uploadTask = await storageRef.putFile(profileImage!);
      final imageurl = uploadTask.ref.getDownloadURL();
      await _firestore.collection('users').doc(id).update({
        'profilePic': imageurl,
      });
    } catch (e) {
      throw Exception("Failed to upload profile image: $e");
    }
  }
}
