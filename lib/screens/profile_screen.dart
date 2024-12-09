import 'package:flutter/material.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'login_screen.dart';

class profileScreen extends StatelessWidget {
  final UserModel userModel;
  final UserController _userController = UserController();

  profileScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${userModel.name} in profile"),
        backgroundColor: Colors.deepPurple[100],
      ),

      // display user data in a very modern way

      body: Column(
        children: [
          Text("Name: ${userModel.name}"),
          Text("Email: ${userModel.email}"),
          Text("Phone Number: ${userModel.phoneNumber}"),
          // user preferences
          Text("Preferences: ${userModel.preferences}"),

          // user delete account
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // background color
            ),
            onPressed: () async {
              await _userController.deleteAccount(userModel, "");
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }
}
