import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/widgets/pledged_gift_card.dart';

class MyPledgedGiftsScreen extends StatefulWidget {
  final UserModel userModel;

  const MyPledgedGiftsScreen({super.key, required this.userModel});

  @override
  _MyPledgedGiftsScreenState createState() => _MyPledgedGiftsScreenState();
}

class _MyPledgedGiftsScreenState extends State<MyPledgedGiftsScreen> {
  final GiftController giftController = GiftController();
  late Future<List<GiftModel>> pledgedGiftsFuture;

  @override
  void initState() {
    super.initState();
    pledgedGiftsFuture = giftController.getMyPledgedGifts(widget.userModel.id);
  }

  // Function to update the list after a gift is unpledged or undone
  void updatePledgedGifts() {
    setState(() {
      pledgedGiftsFuture =
          giftController.getMyPledgedGifts(widget.userModel.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
        title: const Text(
          'My Pledged Gifts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue,
                  Colors.purple,
                  Color.fromARGB(255, 90, 15, 103),
                ],
              ),
            ),
          ),
          FutureBuilder<List<GiftModel>>(
            future: pledgedGiftsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data!.isEmpty) {
                return const Center(child: Text('No pledged gifts.'));
              } else {
                List<GiftModel> pledgedGifts = snapshot.data!;
                return ListView.builder(
                  itemCount: pledgedGifts.length,
                  itemBuilder: (context, index) {
                    final gift = pledgedGifts[index];
                    return PledgedGiftCard(
                      gift: gift,
                      userModel: widget.userModel,
                      onUnpledge: () {
                        updatePledgedGifts(); // Refresh the list when unpledged
                      },
                      onUndo: () {
                        // Trigger the list update when undo is pressed
                        updatePledgedGifts();
                      },
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
