import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hedieaty/screens/login_screen.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final AuthController _authController = AuthController();

  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  void _signUp(BuildContext context) async {
    try {
      final userModel = await _authController.signUp(
        emailController.text,
        passwordController.text,
        nameController.text,
        phoneNumberController.text,
        _profileImage,
      );

      if (userModel != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(userModel: userModel)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number')),
              TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => _signUp(context),
                  child: const Text('Sign Up')),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ),
                child: const Text('Already have account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
