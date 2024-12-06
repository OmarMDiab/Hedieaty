import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel userModel;

  const HomeScreen({required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${userModel.name}!"),
        backgroundColor: Colors.deepPurple[100],
        elevation: 200,
        actions: [
          IconButton(onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          ), icon: const Icon(Icons.logout_rounded),
            tooltip: 'Comment Icon',

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
                Navigator.pushNamed(context, '/profile');
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("N O T I F I C A T I O N S"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),

            // Home Page Tile
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("S E T T I N G S"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
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
