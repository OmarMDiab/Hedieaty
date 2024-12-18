import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/controllers/gift_controller.dart';

class GiftDetailsScreen extends StatefulWidget {
  final GiftModel gift;
  final bool isOwner;
  GiftDetailsScreen({super.key, required this.gift, this.isOwner = true});

  @override
  State<GiftDetailsScreen> createState() => _GiftDetailsScreenState();
}

class _GiftDetailsScreenState extends State<GiftDetailsScreen> {
  final GiftController _giftController = GiftController();
  late String _giftStatus;

  @override
  void initState() {
    super.initState();
    _giftStatus = widget.gift.status; // Local state for gift status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
        title: Text(
          widget.gift.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 10,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent,
                  Colors.deepPurpleAccent,
                  Colors.purpleAccent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 8,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.gift.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      const Divider(
                        color: Colors.deepPurpleAccent,
                        thickness: 2,
                        height: 24,
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        icon: Icons.category,
                        label: 'Category',
                        value: widget.gift.category,
                      ),
                      const SizedBox(height: 16),
                      _detailRow(
                        icon: Icons.description,
                        label: 'Description',
                        value: widget.gift.description,
                      ),
                      const SizedBox(height: 16),
                      _detailRow(
                        icon: Icons.check_circle_outline,
                        label: 'Status',
                        value: _giftStatus, // Use the local state
                      ),
                      const SizedBox(height: 16),
                      _detailRow(
                        icon: Icons.attach_money,
                        label: 'Price',
                        value: "\$${widget.gift.price.toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: 16),
                      _detailRow(
                        icon: Icons.calendar_today,
                        label: 'Due Date',
                        value: widget.gift.dueDate.toString().split(' ')[0],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_giftStatus == 'Available' && !widget.isOwner)
            Positioned(
              bottom: 20,
              left: 40,
              right: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 67, 25, 184),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () async {
                  await _giftController.pledgeGift(widget.gift.id);
                  setState(() {
                    _giftStatus = 'Pledged';
                  });
                },
                child: const Text(
                  'Pledge Gift ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          if (_giftStatus == 'Pledged')
            const Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Text(
                'Gift is pledged! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.deepPurpleAccent,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
