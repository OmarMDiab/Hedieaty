import 'package:cloud_firestore/cloud_firestore.dart';
// gift model      - Gifts (ID, name, description, category, price, status, event ID)

class GiftModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String eventID;

  // Default constructor with optional parameters
  GiftModel({
    this.id = '',
    this.name = '',
    this.description = '',
    this.category = '',
    this.price = 0.0,
    this.status = '',
    this.eventID = '',
  });

  Future<void> saveGift({
    required String id,
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    required String eventID,
  }) async {
    try {
      await _firestore.collection('gifts').doc(id).set({
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'status': status,
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
          eventID: data?['eventID'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching gift: $e');
    }
  }

  Future<List<GiftModel>> fetchGifts(String eventID) async {
    try {
      final snapshot = await _firestore
          .collection('gifts')
          .where('eventID', isEqualTo: eventID)
          .get();
      return snapshot.docs
          .map((doc) => GiftModel(
                id: doc.data()['id'],
                name: doc.data()['name'],
                description: doc.data()['description'],
                category: doc.data()['category'],
                price: doc.data()['price'],
                status: doc.data()['status'],
                eventID: doc.data()['eventID'],
              ))
          .toList();
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
}
