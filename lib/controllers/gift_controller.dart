import '../models/gift_model.dart';

class GiftController {
  final GiftModel _giftModel = GiftModel();

  Future<void> addGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    required DateTime dueDate,
    required String eventID,
  }) async {
    try {
      await _giftModel.saveGift(
        name: name,
        description: description,
        category: category,
        price: price,
        status: status,
        dueDate: dueDate,
        eventID: eventID,
      );
    } catch (e) {
      throw Exception('Error saving gift: $e');
    }
  }

  Future<GiftModel?> fetchGift(String id) async {
    try {
      final gift = await _giftModel.fetchGift(id);
      if (gift != null) {
        return gift;
      }
    } catch (e) {
      throw Exception('Error fetching gift: $e');
    }
    return null;
  }

  Future<void> pledgeGift(String id) async {
    try {
      await _giftModel.updateGiftStatus(id, 'Pledged');
    } catch (e) {
      throw Exception('Error updating gift status: $e');
    }
  }

  // update gift details
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
      await _giftModel.updateGiftDetails(
        id: id,
        name: name,
        description: description,
        category: category,
        price: price,
        status: status,
        dueDate: dueDate,
      );
    } catch (e) {
      throw Exception('Error updating gift: $e');
    }
  }

  // fetch gifts using stream
  Stream<List<GiftModel>> fetchGifts(String eventID) {
    return _giftModel.fetchGifts(eventID);
  }

  // delete gift
  Future<void> deleteGift(String id) async {
    try {
      await _giftModel.deleteGift(id);
    } catch (e) {
      throw Exception('Error deleting gift: $e');
    }
  }
}
