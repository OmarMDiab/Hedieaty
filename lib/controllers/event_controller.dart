import '../models/event_model.dart';

class EventController {
  final EventModel _eventModel = EventModel();

  Future<void> addEvent({
    required String name,
    required DateTime date,
    required String location,
    required String description,
    required String category,
    required String userID,
  }) async {
    try {
      await _eventModel.addEvent(
        name: name,
        date: date,
        location: location,
        category: category,
        description: description,
        userID: userID,
      );
    } catch (e) {
      throw Exception('Error adding event: $e');
    }
  }

  // Future<EventModel?> fetchEvent(String eventID) async {
  //   try {
  //     final event = await _eventModel.fetchEvent(eventID);
  //     if (event != null) {
  //       return event;
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching event: $e');
  //   }
  //   return null;
  // }

  Stream<List<EventModel>> fetchUserEvents(String userID) {
    try {
      return _eventModel.fetchUserEvents(userID);
    } catch (e) {
      throw Exception('Error fetching user events: $e');
    }
  }

  Future<void> updateEvent({
    required String eventID,
    String? name,
    DateTime? date,
    String? location,
    String? description,
    String? category,
    String? userID,
  }) async {
    try {
      await _eventModel.updateEvent(
        id: eventID,
        name: name,
        date: date,
        location: location,
        description: description,
        category: category,
      );
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _eventModel.deleteEvent(id);
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }
}
