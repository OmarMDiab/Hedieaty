import 'package:flutter/material.dart';

import '../models/user_model.dart';


class NotificationScreen extends StatelessWidget {
  final UserModel userModel;

  const NotificationScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification for ${userModel.name}"),
      ),
      
      
    );
  }
}
