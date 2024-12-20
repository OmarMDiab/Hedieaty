import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/widgets/gift_card.dart';
import 'gift_details_screen.dart';
import 'create_gift_screen.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';

class GiftScreen extends StatefulWidget {
  final EventModel eventModel;
  final UserModel userModel;
  final bool isOwner;

  const GiftScreen(
      {super.key,
      required this.eventModel,
      required this.userModel,
      this.isOwner = true});

  @override
  _GiftScreenState createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  final GiftController giftController = GiftController();
  String _sortOption = 'name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
        title: Text(
          'Gift list for ${widget.eventModel.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGiftScreen(
                        eventModel: widget.eventModel,
                        userModel: widget.userModel),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                _sortOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<String>(
                value: 'category',
                child: Text('Sort by Category'),
              ),
              const PopupMenuItem<String>(
                value: 'status',
                child: Text('Sort by Status'),
              ),
              const PopupMenuItem<String>(
                value: 'price',
                child: Text('Sort by Price'),
              ),
            ],
          ),
        ],
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
                  Color.fromARGB(255, 90, 15, 103)
                ],
              ),
            ),
          ),
          StreamBuilder<List<GiftModel>>(
            stream: giftController.fetchGifts(
                widget.eventModel.id, widget.userModel.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data!.isEmpty) {
                return const Center(child: Text('No gifts found.'));
              } else {
                List<GiftModel> gifts = snapshot.data!;
                gifts.sort((a, b) {
                  switch (_sortOption) {
                    case 'name':
                      return a.name.compareTo(b.name);
                    case 'category':
                      return a.category.compareTo(b.category);
                    case 'status':
                      return a.status.compareTo(b.status);
                    case 'price':
                      return a.price.compareTo(b.price);
                    default:
                      return 0;
                  }
                });
                return ListView.builder(
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    return GiftCard(
                      gift: gift,
                      isOwner: widget.isOwner,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftDetailsScreen(
                              gift: gift,
                              userModel: widget.userModel,
                              isOwner: widget.isOwner,
                            ),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGiftScreen(
                              eventModel: widget.eventModel,
                              userModel: widget.userModel,
                              giftModel: gift,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        giftController.deleteGift(gift.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('gift: ${gift.name} deleted'),
                          ),
                        );
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
