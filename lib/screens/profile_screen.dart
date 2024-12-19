import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/screens/signup_screen.dart';
import 'package:hedieaty/widgets/eventCard.dart';
import 'gifts_screen.dart';
import 'login_screen.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'my_pledged_gifts_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final bool isOwner;
  const ProfileScreen(
      {super.key, required this.userModel, this.isOwner = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final EventController _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
        title: Text("${widget.userModel.name} Profile",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        elevation: 0,
      ),
      body: Stack(
        children: [
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage(widget.userModel.pfp),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person,
                          color: Colors.deepPurpleAccent),
                      title: Text(widget.userModel.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Name"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email,
                          color: Colors.deepPurpleAccent),
                      title: Text(widget.userModel.email,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Email"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.phone,
                          color: Colors.deepPurpleAccent),
                      title: Text(widget.userModel.phoneNumber,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Phone Number"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.favorite,
                          color: Colors.deepPurpleAccent),
                      title: Text(widget.userModel.preferences.join(', '),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Preferences"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 67, 25, 184),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyPledgedGiftsScreen(
                                  userModel: widget.userModel)),
                        );
                      },
                      child: const Text(
                        'My Pledged Gifts 💝',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    color: Color.fromARGB(255, 255, 255, 255),
                    thickness: 4,
                    indent: 5,
                    endIndent: 5,
                  ),
                  // Title for events
                  const Center(
                    child: Text(
                      "Your Events/Gifts Lists",
                      style: TextStyle(
                        fontSize: 22,
                        decorationColor: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display all events inline
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Colors.transparent,
                    child: StreamBuilder<List<EventModel>>(
                      stream:
                          _eventController.fetchUserEvents(widget.userModel.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No events found.',
                                  style: TextStyle(color: Colors.black)));
                        } else {
                          var events = snapshot.data!;

                          return SizedBox(
                            height: 220, // Set a fixed height
                            child: ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GiftScreen(
                                          eventModel: event,
                                          userModel: widget.userModel,
                                          isOwner: widget.isOwner,
                                        ),
                                      ),
                                    );
                                  },
                                  child: EventCard(
                                    event: event,
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 195, 31, 31),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 67, 25, 184),
              onPressed: () {
                // Navigate to edit profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(
                        isEditMode: true, userModel: widget.userModel),
                  ),
                );
                setState(() {});
              },
              tooltip: 'Edit Profile',
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
