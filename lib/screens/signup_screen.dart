import 'package:flutter/material.dart';
import 'package:hedieaty/screens/login_screen.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'package:hedieaty/widgets/CustomTextField.dart';

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

  int _selectedImageIndex = 0;

  // List of asset paths for profile images
  final List<String> _profileImages = List.generate(
    5,
    (index) => 'assets/images/Profilepfp/pfp${index + 1}.png',
  );

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _signUp(BuildContext context) async {
    try {
      // Get the selected image asset path
      final selectedImagePath = _profileImages[_selectedImageIndex];

      final userModel = await _authController.signUp(
        emailController.text,
        passwordController.text,
        nameController.text,
        phoneNumberController.text,
        selectedImagePath, // Pass the asset path
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
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Create Account',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Subtitle
              const Text('Join Hedieaty! 🎁',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),

              const SizedBox(height: 20),

              // Profile Image Selector
              const Text('Select Profile Picture',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _profileImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final imagePath = entry.value;
                    return GestureDetector(
                      onTap: () => _selectImage(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedImageIndex == index
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),

              // Email TextField
              CustomTextField(
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),

              // Name TextField
              CustomTextField(
                controller: nameController,
                labelText: 'Name',
                icon: Icons.person,
              ),

              // Phone Number TextField
              CustomTextField(
                controller: phoneNumberController,
                labelText: 'Phone Number',
                icon: Icons.phone,
              ),

              // Password TextField
              CustomTextField(
                  controller: passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true),

              const SizedBox(height: 30),

              // Sign Up Button
              ElevatedButton(
                onPressed: () => _signUp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Signup',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),

              const SizedBox(height: 20),

              // Already have an account
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: const Text('Already have an account? Login',
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
