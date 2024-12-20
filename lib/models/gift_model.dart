import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/services/push_notification_service.dart';
import 'package:hedieaty/services/sqlite_helper.dart';
import 'package:hedieaty/controllers/auth_controller.dart';

class GiftModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();

  String id;
  String name;
  String description;
  String category;
  double price;
  String status;
  DateTime dueDate;
  String eventID;
  String pledgedBy;
  String createdBy;
  String? imageBase64;
  bool isPublished;

  GiftModel({
    this.id = '',
    this.name = '',
    this.description = '',
    this.category = '',
    this.price = 0.0,
    this.status = 'not',
    DateTime? dueDate,
    this.eventID = '',
    this.pledgedBy = '',
    this.createdBy = '',
    this.imageBase64 = '',
    this.isPublished = false,
  }) : dueDate = dueDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'eventID': eventID,
      'pledgedBy': pledgedBy,
      'createdBy': createdBy,
      'imageBase64': imageBase64,
      'isPublished': isPublished ? 1 : 0,
    };
  }

  static GiftModel fromMap(Map<String, dynamic> map) {
    return GiftModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      dueDate: DateTime.parse(map['dueDate']),
      eventID: map['eventID'],
      pledgedBy: map['pledgedBy'],
      createdBy: map['createdBy'],
      imageBase64: map['imageBase64'],
      isPublished: map['isPublished'] == 1,
    );
  }

  Future<void> addGift({
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
    final gift = GiftModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      price: price,
      status: status,
      dueDate: dueDate,
      eventID: eventID,
      pledgedBy: '',
      createdBy: createdBy,
      imageBase64: imageBase64,
    );
    await SQLiteHelper().insertData('gifts', gift.toMap());
  }

  Future<void> publishGift(String id) async {
    try {
      await SQLiteHelper().updateData('gifts', id, {'isPublished': 1});
      await _firestore.collection('gifts').doc(id).set(toMap());
      isPublished = true;
    } catch (e) {
      throw Exception('Error publishing gift: $e');
    }
  }

  bool isGiftPublished() {
    // from sqlite
    return isPublished;
  }

  Future<void> deleteGift(String id) async {
    await SQLiteHelper().deleteData('gifts', id);
    if (isPublished) {
      await _firestore.collection('gifts').doc(id).delete();
    }
  }

  Future<void> updateGiftDetails({
    required String id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    DateTime? dueDate,
    String? pledgedBy,
    String? imageBase64,
  }) async {
    final updatedData = {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
      if (status != null) 'status': status,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      if (pledgedBy != null) 'pledgedBy': pledgedBy,
      if (imageBase64 != null) 'imageBase64': imageBase64,
    };
    await SQLiteHelper().updateData('gifts', id, updatedData);
    if (isPublished) {
      await _firestore.collection('gifts').doc(id).update(updatedData);
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

  Stream<List<GiftModel>> fetchGifts(String eventID, String userID) async* {
    if (_authController.getCurrentUserID() != userID) {
      try {
        yield* _firestore
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
                      pledgedBy: doc.data()['pledgedBy'] ?? '',
                      createdBy: doc.data()['createdBy'],
                      imageBase64: doc.data()['imageBase64'] ?? '',
                    ))
                .toList());
      } catch (e) {
        throw Exception('Error fetching gifts: $e');
      }
    } else {
      final stream = SQLiteHelper().getStream('gifts', 'eventID', eventID);
      await for (final data in stream) {
        yield data.map((map) => GiftModel.fromMap(map)).toList();
      }
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
          createdBy: data['createdBy'],
          imageBase64: data['imageBase64'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching gifts pledged by user: $e');
    }
  }
}
