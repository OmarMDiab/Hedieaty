import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel userModel;

  const HomeScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${userModel.phoneNumber}!"),
        backgroundColor: Colors.deepPurple[100],
        elevation: 200,
        actions: [
          IconButton(onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          ), icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout', // for user to know

          )
        ],
      ),

      drawer: Drawer(
        backgroundColor: Colors.deepPurple[100],
        child:  Column(
          children: [
            const DrawerHeader(child:
            Icon(Icons.card_giftcard, size: 40,)
            ),

            // Home Page Tiles
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("P R O F I L E"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profileScreen(userModel: userModel)),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("N O T I F I C A T I O N S"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen(userModel: userModel)),
                );
              },
            ),

            // Home Page Tile
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("S E T T I N G S"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(userModel: userModel)),
                );
              },
            ),
          ],
        ),
      ),


      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  Text("test.........")
          ],
        ),
      ),
    );
  }
}
