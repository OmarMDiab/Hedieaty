import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty/controllers/gift_controller.dart';

class PledgedGiftCard extends StatelessWidget {
  final GiftModel gift;
  final UserModel userModel;
  final VoidCallback onUnpledge; // Callback for unpledge action
  final VoidCallback onUndo; // Callback for undo action

  const PledgedGiftCard({
    super.key,
    required this.gift,
    required this.userModel,
    required this.onUnpledge, // Receiving the unpledge callback
    required this.onUndo, // Receiving the undo callback
  });

  @override
  Widget build(BuildContext context) {
    // Convert due date to a readable format
    String formattedDate = DateFormat('dd MMM yyyy').format(gift.dueDate);
    final GiftController giftController = GiftController();

    // Check if the pledge can be modified or unpledged (before due date)
    bool canModifyPledge = DateTime.now().isBefore(gift.dueDate);

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: Colors.deepPurple[50],
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gift Image
                if (gift.imageBase64 != null &&
                    gift.imageBase64!.isNotEmpty) ...[
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(gift.imageBase64!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Gift Name and Creator
                Row(
                  children: [
                    Text(
                      gift.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(9.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 146, 106, 255),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'Pledged for: ${gift.CreatedBy}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Due Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      "Due date: $formattedDate",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.description, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Description: ${gift.description}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Unpledge Button
                if (canModifyPledge)
                  ElevatedButton(
                    onPressed: () {
                      giftController.changeGiftStatus(
                          gift, userModel, 'Available');
                      // Call the callback to update the list
                      onUnpledge();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Pledge removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              giftController.changeGiftStatus(
                                  gift, userModel, 'Pledged');
                              // Call the undo callback to refresh the list
                              onUndo();
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Unpledge'),
                  )
                else
                  const Text(
                    'Pledge expired',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 20,
          child: Container(
            width: 100,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color.fromARGB(255, 146, 106, 255),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                "💲${gift.price.toString()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
