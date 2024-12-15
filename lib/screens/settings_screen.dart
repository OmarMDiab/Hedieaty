import 'package:flutter/material.dart';
import 'package:hedieaty/models/user_model.dart';

class SettingsScreen extends StatelessWidget {
  final UserModel userModel;

  const SettingsScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Center(
          child: Text('Welcome to Hedieaty! 🎁',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        elevation: 0,
      ),
    );
  }
}
