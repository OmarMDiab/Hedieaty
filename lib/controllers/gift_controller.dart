import '../models/gift_model.dart';

class GiftController {
  final GiftModel _giftModel = GiftModel();

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
      await _giftModel.saveGift(
        id: id,
        name: name,
        description: description,
        category: category,
        price: price,
        status: status,
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

  Future<void> updateGiftStatus(String id, String status) async {
    try {
      await _giftModel.updateGiftStatus(id, status);
    } catch (e) {
      throw Exception('Error updating gift status: $e');
    }
  }
}
