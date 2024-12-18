import 'package:flutter/material.dart';
import 'package:hedieaty/screens/login_screen.dart';
import 'package:hedieaty/screens/profile_screen.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/widgets/CustomTextField.dart';
import 'package:hedieaty/controllers/user_controller.dart';

class SignupScreen extends StatefulWidget {
  final bool isEditMode;
  final UserModel? userModel;

  const SignupScreen({super.key, this.isEditMode = false, this.userModel});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneNumberController;
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();
  List<String> preferences = [];
  late TextEditingController preferencesController = TextEditingController();

  int _selectedImageIndex = 0;

  // List of asset paths for profile images
  final List<String> _profileImages = List.generate(
    5,
    (index) => 'assets/images/Profilepfp/pfp${index + 1}.png',
  );

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if in edit mode
    nameController = TextEditingController(
        text: widget.isEditMode ? widget.userModel?.name : '');
    emailController = TextEditingController(
        text: widget.isEditMode ? widget.userModel?.email : '');
    passwordController = TextEditingController(); // Password should not prefill
    phoneNumberController = TextEditingController(
        text: widget.isEditMode ? widget.userModel?.phoneNumber : '');

    preferences = widget.isEditMode ? widget.userModel?.preferences ?? [] : [];

    // Preselect the user's profile picture if in edit mode
    if (widget.isEditMode && widget.userModel != null) {
      _selectedImageIndex = _profileImages.indexOf(widget.userModel!.pfp);
    }
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _submit(BuildContext context) async {
    try {
      final selectedImagePath = _profileImages[_selectedImageIndex];

      if (widget.isEditMode && widget.userModel != null) {
        // Edit profile logic
        var updatedUser = widget.userModel!.copyWith(
          name: nameController.text,
          email: emailController.text,
          phoneNumber: phoneNumberController.text,
          pfp: selectedImagePath,
          preferences: preferences,
        );

        await _userController.updateUserProfile(updatedUser);
        // Navigator.pop(context, updatedUserResult);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(userModel: updatedUser)),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userModel: updatedUser)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color.fromARGB(255, 149, 71, 238),
          ),
        );
      } else {
        // Sign up logic
        final userModel = await _authController.signUp(
            emailController.text,
            passwordController.text,
            nameController.text,
            phoneNumberController.text,
            selectedImagePath,
            preferences);

        if (userModel != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(userModel: userModel)),
          );
        }
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
        title: Text(widget.isEditMode ? 'Edit Profile' : 'Create Account',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Subtitle
              Text(
                widget.isEditMode ? 'Update Your Details' : 'Join Hedieaty! 🎁',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),

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
              if (!widget.isEditMode)
                CustomTextField(
                  controller: emailController,
                  labelText: widget.isEditMode ? 'Edit Email' : 'Email',
                  icon: Icons.email,
                ),

              // Name TextField
              CustomTextField(
                controller: nameController,
                labelText: widget.isEditMode ? 'Edit Name' : 'Name',
                icon: Icons.person,
              ),

              // Phone Number TextField
              CustomTextField(
                controller: phoneNumberController,
                labelText:
                    widget.isEditMode ? 'Edit Phone Number' : 'Phone Number',
                icon: Icons.phone,
              ),

              // Password TextField (only for signup)
              if (!widget.isEditMode)
                CustomTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    icon: Icons.lock,
                    obscureText: true),

// Preferences TextField
              CustomTextField(
                controller: preferencesController,
                labelText:
                    widget.isEditMode ? 'Edit Preferences' : 'Preferences',
                icon: Icons.favorite,
              ),

              // Add a button to add preferences
              ElevatedButton(
                onPressed: () {
                  if (preferencesController.text.isNotEmpty) {
                    setState(() {
                      preferences.add(preferencesController.text);
                      preferencesController.clear();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preference cannot be empty'),
                        backgroundColor: Color.fromARGB(255, 187, 46, 36),
                      ),
                    );
                  }
                },
                child: const Text('Add Preference'),
              ),

              // Display the list of preferences
              Wrap(
                spacing: 8.0,
                children: preferences.map((preference) {
                  return Chip(
                    label: Text(preference),
                    backgroundColor: Colors.deepPurpleAccent,
                    labelStyle: const TextStyle(color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        preferences.remove(preference);
                      });
                    },
                    deleteIconColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.isEditMode ? 'Save Changes' : 'Signup',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),

              const SizedBox(height: 20),

              // Already have an account (only for signup)
              if (!widget.isEditMode)
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
