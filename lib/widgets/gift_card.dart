import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class GiftCard extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPublish;
  final bool isOwner;

  const GiftCard({
    super.key,
    required this.gift,
    this.onTap,
    this.isOwner = true,
    this.onEdit,
    this.onDelete,
    this.onPublish,
  });

  Widget _buildTrailingButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          elevation: 8,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: gift.status == 'Pledged' ? Colors.green : Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            onTap: onTap,
            leading: gift.imageBase64 != null && gift.imageBase64!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      base64Decode(gift.imageBase64!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.card_giftcard,
                    color: Colors.pinkAccent, size: 35),
            title: Text(
              gift.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.category,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Due Date: ${DateFormat('dd MMM yyyy').format(gift.dueDate)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: isOwner && gift.status != 'Pledged'
                ? _buildTrailingButtons()
                : null,
          ),
        ),
        if (!gift.isPublished && isOwner)
          ElevatedButton.icon(
            onPressed: onPublish,
            icon: const Icon(Icons.publish, color: Colors.white),
            label: const Text('Publish', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
      ],
    );
  }
}
