import 'package:flutter/material.dart';
import 'package:hedieaty/screens/signup_screen.dart';
import 'package:hedieaty/widgets/CustomTextField.dart'; // Import CustomTextField widget
import '../controllers/auth_controller.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  LoginScreen({super.key});

  void _login(BuildContext context) async {
    try {
      final userModel = await _authController.login(
        emailController.text,
        passwordController.text,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 67, 25, 184),
            title: const Center(
              child: Text('Welcome to Hedieaty! 🎁',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Subtitle

              //const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/boxes/login.png',
                  height: 200,
                ),
              ),
              const Center(
                child: Text(
                  'For it is in giving that we receive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 152, 97, 135),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Email TextField
              CustomTextField(
                key: const Key('emailField'),
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),

              // Password TextField
              CustomTextField(
                key: const Key('passwordField'),
                controller: passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                key: const Key('loginButton'),
                onPressed: () => _login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),

              const SizedBox(height: 20),

              // Don’t have an account? Sign Up
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()),
                  ),
                  child: const Text('Don’t have an account? Sign Up',
                      style: TextStyle(color: Colors.deepPurple)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
