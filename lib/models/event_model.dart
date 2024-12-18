import 'package:cloud_firestore/cloud_firestore.dart';

//- Events (ID, name, date, location, description, user ID)

class EventModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String category;
  final int numberOfGifts;
  final String userID;

  EventModel({
    this.id = '',
    this.name = '',
    DateTime? date,
    this.location = '',
    this.category = '',
    this.description = '',
    this.numberOfGifts = 0,
    this.userID = '',
  }) : date = date ?? DateTime.now();

  Future<void> addEvent({
    required String name,
    required DateTime date,
    required String location,
    required String description,
    required String category,
    required String userID,
  }) async {
    try {
      DocumentReference docRef = _firestore.collection('events').doc();
      await docRef.set({
        'id': docRef.id,
        'name': name,
        'date': date,
        'location': location,
        'category': category,
        'description': description,
        'userID': userID,
      });
    } catch (e) {
      throw Exception('Error saving event: $e');
    }
  }

  Future<EventModel?> fetchEvent(String id) async {
    try {
      final doc = await _firestore.collection('events').doc(id).get();
      if (doc.exists) {
        final giftdocs = await _firestore
            .collection('gifts')
            .where('eventID', isEqualTo: id)
            .get();

        final numberOfGifts = giftdocs.docs.length;
        var eventData = doc.data();
        return EventModel(
          id: id,
          name: eventData?['name'],
          date: eventData?['date'].toDate(),
          location: eventData?['location'],
          category: eventData?['category'],
          description: eventData?['description'],
          numberOfGifts: numberOfGifts,
          userID: eventData?['userID'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  // fetch all user events

  Stream<List<EventModel>> fetchUserEvents(String userID) {
    try {
      return _firestore
          .collection('events')
          .where('userID', isEqualTo: userID)
          .snapshots()
          .asyncMap((snapshot) async {
        List<EventModel> events = [];
        for (var doc in snapshot.docs) {
          var data = doc.data();
          final giftdocs = await _firestore
              .collection('gifts')
              .where('eventID', isEqualTo: doc.id)
              .get();
          final numberOfGifts = giftdocs.docs.length;
          events.add(EventModel(
            id: doc.id,
            name: data['name'],
            date: data['date'].toDate(),
            location: data['location'],
            category: data['category'],
            description: data['description'],
            numberOfGifts: numberOfGifts,
            userID: data['userID'],
          ));
        }
        return events;
      });
    } catch (e) {
      throw Exception('Error fetching user events: $e');
    }
  }

  Future<void> updateEvent({
    required String id,
    String? name,
    DateTime? date,
    String? location,
    String? description,
    String? userID,
  }) async {
    try {
      Map<String, dynamic> updatedData = {};
      if (name != null) updatedData['name'] = name;
      if (date != null) updatedData['date'] = date;
      if (location != null) updatedData['location'] = location;
      if (description != null) updatedData['description'] = description;
      if (userID != null) updatedData['userID'] = userID;

      await _firestore.collection('events').doc(id).update(updatedData);
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }
}
