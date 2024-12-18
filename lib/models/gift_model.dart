import 'package:cloud_firestore/cloud_firestore.dart';
// gift model      - Gifts (ID, name, description, category, price, status, event ID)

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
  }) : dueDate = dueDate ?? DateTime.now();

  Future<void> saveGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    required DateTime dueDate,
    required String eventID,
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
                  ))
              .toList());
    } catch (e) {
      throw Exception('Error fetching gifts: $e');
    }
  }

  Future<void> updateGiftStatus(String id, String status) async {
    try {
      await _firestore.collection('gifts').doc(id).update({
        'status': status,
      });
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
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (price != null) updateData['price'] = price;
      if (status != null) updateData['status'] = status;
      if (dueDate != null) updateData['dueDate'] = dueDate;

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
}
