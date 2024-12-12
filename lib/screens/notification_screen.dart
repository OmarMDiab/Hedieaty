import 'package:flutter/material.dart';

import '../models/user_model.dart';

class NotificationScreen extends StatelessWidget {
  final UserModel userModel;

  const NotificationScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Center(
          child: const Text('Welcome to Hedieaty! 🎁',
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
