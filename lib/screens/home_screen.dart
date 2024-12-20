import 'package:flutter/material.dart';
import 'package:hedieaty/services/get_notification_service.dart';
import 'create_event_screen.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import '../controllers/user_controller.dart';
import 'events_screen.dart';
import 'login_screen.dart';
import 'package:hedieaty/widgets/CustomTextField.dart';
import 'package:hedieaty/widgets/friendCard.dart';
import 'package:hedieaty/services/push_notification_service.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;

  const HomeScreen({super.key, required this.userModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserController _userController = UserController();
  @override
  void initState() {
    super.initState();
    GetNotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
        //backgroundColor: Colors.deepPurpleAccent,
        title: Center(
          child: Text(
            "Welcome, ${widget.userModel.name}!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 10,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        backgroundColor: Colors.deepPurple[100],
        child: Column(
          children: [
            const DrawerHeader(
              child: Icon(Icons.card_giftcard, size: 80),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(userModel: widget.userModel)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Events"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EventScreen(userModel: widget.userModel)),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // colors: [
                //   Color.fromARGB(223, 213, 44, 232),
                //   Color.fromARGB(255, 81, 43, 186)
                // ],
                // colors: [
                //   Color.fromARGB(223, 170, 55, 241),
                //   Color.fromARGB(255, 43, 6, 87)
                // ],
                colors: [
                  Color.fromARGB(223, 246, 107, 220),
                  Color.fromARGB(255, 145, 78, 233),
                  Color.fromARGB(255, 53, 37, 169)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Friends List Section
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: FutureBuilder<List<UserModel>>(
              future: _userController.getFriends(widget.userModel.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading friends'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No friends found'));
                } else {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        UserModel friend = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventScreen(
                                        userModel: friend,
                                        isOwner: false,
                                      )),
                            );
                          },
                          child: FriendCard(friend: friend),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 50, // Custom width
              height: 50, // Custom height
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 67, 25, 184),
                onPressed: () {
                  _showSearchDialog(context, searchController);
                },
                tooltip: 'Add Friend',
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 20, // Adjusted the size of the icon
                ),
              ),
            ),
          ),

          // Button for Event Creation
          Positioned(
            top: 16,
            left: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 67, 25, 184),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateEventScreen(userModel: widget.userModel)),
                );
              },
              child: const Text(
                'Create Your Own Event/List',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(
      BuildContext context, TextEditingController searchController) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Add Friend',
            style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: CustomTextField(
            key: const Key('friendPhoneField'),
            controller: searchController,
            labelText: 'Friend phone',
            icon: Icons.phone,
            padding: const EdgeInsets.only(bottom: 0.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              key: const Key('addFriendButton'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                String phoneNumber = searchController.text.trim();
                if (phoneNumber.isNotEmpty) {
                  _userController
                      .addFriend(widget.userModel.id, phoneNumber)
                      .then((friendToken) {
                    if (friendToken != null) {
                      // Send a push notification

                      PushNotificationService.sendPushNotificationToAddedFriend(
                        friendToken,
                        widget.userModel.name,
                      );
                    }
                    Navigator.pop(context);
                    setState(() {});
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a phone number.')),
                  );
                }
              },
              child: const Text('Add Friend',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
