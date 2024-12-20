import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/controllers/auth_controller.dart';

class GiftDetailsScreen extends StatefulWidget {
  final GiftModel gift;
  final bool isOwner;
  final UserModel userModel;
  const GiftDetailsScreen(
      {super.key,
      required this.gift,
      required this.userModel,
      this.isOwner = true});

  @override
  State<GiftDetailsScreen> createState() => _GiftDetailsScreenState();
}

class _GiftDetailsScreenState extends State<GiftDetailsScreen> {
  final GiftController _giftController = GiftController();
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();
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
          '${widget.gift.name} Details',
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
          // Background gradient
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Gift details card
                  Card(
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
                          // Display image if available
                          if (widget.gift.imageBase64 != null &&
                              widget.gift.imageBase64!.isNotEmpty)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.memory(
                                  base64Decode(widget.gift.imageBase64!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

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
                          const SizedBox(height: 16),
                          if (_giftStatus == 'Pledged')
                            Center(
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.green.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Colors.green, width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: _detailRow(
                                    icon:
                                        Icons.sentiment_satisfied_alt_outlined,
                                    label: 'Status',
                                    value: _giftStatus, // Use the local state
                                  ),
                                ),
                              ),
                            )
                          else
                            Center(
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.red.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: _detailRow(
                                    icon: Icons.sentiment_dissatisfied_outlined,
                                    label: 'Status',
                                    value: _giftStatus, // Use the local state
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Pledge Gift button if the gift is available
                  if (_giftStatus == 'Available' && !widget.isOwner) ...[
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () async {
                        final userModel = await _userController
                            .fetchUser(_authController.getCurrentUserID()!);
                        await _giftController.changeGiftStatus(
                            widget.gift, userModel, 'Pledged');
                        setState(() {
                          _giftStatus = 'Pledged';
                        });
                      },
                      child: const Text(
                        'Pledge Gift ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],

                  // Gift pledged message
                  if (_giftStatus == 'Pledged') ...[
                    const SizedBox(height: 15),
                    const Text(
                      'Gift is pledged 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                ],
              ),
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
