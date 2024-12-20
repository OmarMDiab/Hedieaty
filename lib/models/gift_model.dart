import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/services/push_notification_service.dart';

class GiftModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  late final String status; // pledged or not
  final DateTime dueDate;
  final String eventID;
  final String pledgedBy;
  final String CreatedBy;
  final String? imageBase64;

  // Default constructor with optional parameters
  GiftModel({
    this.id = '',
    this.name = '',
    this.description = '',
    this.category = '',
    this.price = 0.0,
    this.status = '',
    DateTime? dueDate,
    this.eventID = '',
    this.pledgedBy = '',
    this.CreatedBy = '',
    this.imageBase64 = '',
  }) : dueDate = dueDate ?? DateTime.now();

  Future<void> saveGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    required DateTime dueDate,
    required String eventID,
    required String createdBy,
    String? imageBase64,
  }) async {
    try {
      final docRef = _firestore.collection('gifts').doc();
      await docRef.set({
        'id': docRef.id,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'status': status,
        'dueDate': dueDate,
        'eventID': eventID,
        'pledgedBy': '',
        'createdBy': createdBy,
        'imageBase64': imageBase64,
      });
    } catch (e) {
      throw Exception('Error saving gift: $e');
    }
  }

  Future<GiftModel?> fetchGift(String id) async {
    try {
      final doc = await _firestore.collection('gifts').doc(id).get();
      if (doc.exists) {
        var data = doc.data();
        return GiftModel(
          id: id,
          name: data?['name'],
          description: data?['description'],
          category: data?['category'],
          price: data?['price'],
          status: data?['status'],
          dueDate: data?['dueDate'].toDate(),
          eventID: data?['eventID'],
          pledgedBy: data?['pledgedBy'],
          CreatedBy: data?['createdBy'],
          imageBase64: data?['imageBase64'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching gift: $e');
    }
  }

  Stream<List<GiftModel>> fetchGifts(String eventID) {
    try {
      return _firestore
          .collection('gifts')
          .where('eventID', isEqualTo: eventID)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => GiftModel(
                    id: doc.data()['id'],
                    name: doc.data()['name'],
                    description: doc.data()['description'],
                    category: doc.data()['category'],
                    price: doc.data()['price'],
                    status: doc.data()['status'],
                    dueDate: doc.data()['dueDate'].toDate(),
                    eventID: doc.data()['eventID'],
                    pledgedBy: doc.data()['pledgedBy'],
                    CreatedBy: doc.data()['createdBy'],
                    imageBase64: doc.data()['imageBase64'] ?? '',
                  ))
              .toList());
    } catch (e) {
      throw Exception('Error fetching gifts: $e');
    }
  }

  Future<void> updateGiftStatus(
      GiftModel giftModel, UserModel userModel, String status) async {
    try {
      // Send push notification to the user who added the gift
      final eventID = await _firestore
          .collection('gifts')
          .doc(giftModel.id)
          .get()
          .then((value) => value.data()?['eventID']);
      final eventDoc = await _firestore.collection('events').doc(eventID).get();
      final userDoc = await _firestore
          .collection('users')
          .doc(eventDoc.data()?['userID'])
          .get();
      final userDeviceToken = userDoc.data()?['deviceToken'];

      if (status == 'Pledged') {
        await _firestore.collection('gifts').doc(giftModel.id).update({
          'status': status,
          'pledgedBy': userModel.id,
        });

        PushNotificationService.sendPushNotificationToGiftOwner(
            userDeviceToken, userModel.name, giftModel.name, status);
      } else {
        await _firestore.collection('gifts').doc(giftModel.id).update({
          'status': status,
          'pledgedBy': '',
        });

        PushNotificationService.sendPushNotificationToGiftOwner(
            userDeviceToken, userModel.name, giftModel.name, status);
      }
    } catch (e) {
      throw Exception('Error updating gift status: $e');
    }
  }

  // updateGiftDetails
  Future<void> updateGiftDetails({
    required String id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    DateTime? dueDate,
    String? imageBase64,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (price != null) updateData['price'] = price;
      if (status != null) updateData['status'] = status;
      if (dueDate != null) updateData['dueDate'] = dueDate;
      if (imageBase64 != null) updateData['imageBase64'] = imageBase64;

      await _firestore.collection('gifts').doc(id).update(updateData);
    } catch (e) {
      throw Exception('Error updating gift: $e');
    }
  }

  Future<void> deleteGift(String id) async {
    try {
      await _firestore.collection('gifts').doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting gift: $e');
    }
  }

  Future<List<GiftModel>> getGiftsPledgedBy(String userID) async {
    try {
      final querySnapshot = await _firestore
          .collection('gifts')
          .where('pledgedBy', isEqualTo: userID)
          .get();

      return querySnapshot.docs.map((doc) {
        var data = doc.data();
        return GiftModel(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          category: data['category'],
          price: data['price'],
          status: data['status'],
          dueDate: data['dueDate'].toDate(),
          eventID: data['eventID'],
          pledgedBy: data['pledgedBy'],
          CreatedBy: data['createdBy'],
          imageBase64: data['imageBase64'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching gifts pledged by user: $e');
    }
  }
}
