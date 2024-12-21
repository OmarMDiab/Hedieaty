// SQLiteHelper, GiftModel completed.

// EventModel
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/controllers/auth_controller.dart';
import 'package:hedieaty/services/sqlite_helper.dart';
// get current user id

class EventModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();

  String id;
  String name;
  DateTime date;
  String location;
  String category;
  String description;
  String userID;
  bool isPublished;
  int numberOfGifts;

  EventModel({
    this.id = '',
    this.name = '',
    DateTime? date,
    this.location = '',
    this.category = '',
    this.description = '',
    this.userID = '',
    this.isPublished = false,
    this.numberOfGifts = 0,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'description': description,
      'userID': userID,
      'isPublished': isPublished ? 1 : 0,
    };
  }

  static EventModel fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      category: map['category'],
      description: map['description'],
      userID: map['userID'],
      numberOfGifts: map['numberOfGifts'] ?? 0,
      isPublished: map['isPublished'] == 1,
    );
  }

  Future<void> addEvent({
    required String name,
    required DateTime date,
    required String location,
    required String category,
    required String description,
    required String userID,
  }) async {
    final event = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: date,
      location: location,
      category: category,
      description: description,
      userID: userID,
    );
    await SQLiteHelper().insertData('events', event.toMap());
  }

  Future<void> publishEvent(String eventId) async {
    try {
      final localEvent = await SQLiteHelper().fetchDataById('events', eventId);
      if (localEvent != null) {
        await SQLiteHelper().updateData('events', eventId, {'isPublished': 1});
        final event = EventModel.fromMap(localEvent);
        event.isPublished = true;
        await _firestore.collection('events').doc(eventId).set(event.toMap());
      }
    } catch (e) {
      throw Exception('Error publishing event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final localEvent = await SQLiteHelper().fetchDataById('events', eventId);
    final event = EventModel.fromMap(localEvent!);
    await SQLiteHelper().deleteData('events', eventId);
    if (event.isPublished) {
      await _firestore.collection('events').doc(eventId).delete();
    }
  }

  Future<void> updateEvent({
    required String id,
    String? name,
    DateTime? date,
    String? location,
    String? category,
    String? description,
  }) async {
    final updatedData = {
      if (name != null) 'name': name,
      if (date != null) 'date': date.toIso8601String(),
      if (location != null) 'location': location,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
    };
    final localEvent = await SQLiteHelper().fetchDataById('events', id);
    final event = EventModel.fromMap(localEvent!);
    await SQLiteHelper().updateData('events', id, updatedData);
    if (event.isPublished) {
      await _firestore.collection('events').doc(id).update(updatedData);
    }
  }

  Stream<List<EventModel>> fetchUserEvents(String userID) {
    if (_authController.getCurrentUserID() != userID) {
      // fetch from firebase
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
            date: DateTime.parse(data['date']),
            location: data['location'],
            category: data['category'],
            description: data['description'],
            numberOfGifts: numberOfGifts,
            userID: data['userID'],
          ));
        }
        return events;
      });
    } else {
      // fetch from SQLite database
      return SQLiteHelper()
          .getStream('events', "userID", userID)
          .asyncExpand((snapshot) async* {
        // Create a list to hold the final results
        List<EventModel> eventList = [];

        // Create a list of futures to fetch gifts for each event concurrently
        List<Future<void>> futures = [];

        for (var data in snapshot) {
          // Add a future that will process each event and its corresponding gifts
          futures.add(
            SQLiteHelper()
                .fetchByColumn('gifts', 'eventID', data['id'])
                .then((gifts) {
              final numberOfGifts = gifts.length;
              eventList
                  .add(EventModel.fromMap(data)..numberOfGifts = numberOfGifts);
            }),
          );
        }

        // Wait for all futures to complete
        await Future.wait(futures);

        // Once all the data is fetched, yield the full list
        yield eventList;
      });
    }
  }
}
