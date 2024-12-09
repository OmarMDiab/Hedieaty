import 'package:flutter/material.dart';
import 'package:hedieaty/models/user_model.dart';
class SettingsScreen extends StatelessWidget {
  final UserModel userModel;
  
  const SettingsScreen({super.key,  required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings for ${userModel.name}'),
      ),
      
    );
  }
}
