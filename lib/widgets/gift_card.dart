import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';

class GiftCard extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  GiftCard({
    super.key,
    required this.gift,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      child: ListTile(
        onTap: onTap,
        leading:
            const Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 35),
        title: Text(
          gift.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${gift.category} - ${gift.status}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: _buildTrailingButtons(),
      ),
    );
  }
}
