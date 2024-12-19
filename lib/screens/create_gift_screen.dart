import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/widgets/CustomTextField.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker

class CreateGiftScreen extends StatefulWidget {
  final GiftModel? giftModel;
  final EventModel eventModel;
  final UserModel userModel;

  const CreateGiftScreen({
    super.key,
    required this.eventModel,
    required this.userModel,
    this.giftModel,
  });

  @override
  _CreateGiftScreenState createState() => _CreateGiftScreenState();
}

class _CreateGiftScreenState extends State<CreateGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _giftNameController = TextEditingController();
  final _giftDescriptionController = TextEditingController();
  final _giftPriceController = TextEditingController();
  final _dueDateController = TextEditingController();

  String? _selectedCategory;
  String? _imageBase64; // To store the Base64 encoded image

  final List<String> _categories = [
    'games 🎮',
    'Toys 🧸',
    'Clothing 👕',
    'Books 📚',
    'Jewelry 💍',
    'Electronics 📱',
    'Cakes 🎂',
    'Flowers 💐',
    'Your choice 🎁',
  ];

  @override
  void dispose() {
    _giftNameController.dispose();
    _giftDescriptionController.dispose();
    _giftPriceController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.giftModel != null) {
      _giftNameController.text = widget.giftModel!.name;
      _giftDescriptionController.text = widget.giftModel!.description;
      _giftPriceController.text = widget.giftModel!.price.toString();
      _dueDateController.text =
          widget.giftModel!.dueDate.toIso8601String().split('T')[0];
      _selectedCategory = widget.giftModel!.category;
      _imageBase64 =
          widget.giftModel?.imageBase64; // Fetch encoded image if exists
    }
  }

  Future<void> _pickDueDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _dueDateController.text = selectedDate.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _requestImagePermission() async {
    // Request permission for photos
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      _pickImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied!')),
      );
    }
  }

  Future<void> _pickImage() async {
    // Pick an image from the gallery
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Convert the image to Base64
      final imageBytes = await image.readAsBytes();
      setState(() {
        _imageBase64 =
            base64Encode(imageBytes); // Store the image as Base64 text
      });
    }
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      if (widget.giftModel == null) {
        // Create new gift
        GiftController().addGift(
          eventID: widget.eventModel.id,
          name: _giftNameController.text,
          description: _giftDescriptionController.text,
          category: _selectedCategory!,
          price: double.parse(_giftPriceController.text),
          status: 'Available',
          dueDate: DateTime.parse(_dueDateController.text),
          createdBy: widget.userModel.name,
          imageBase64: _imageBase64, // Save the Base64 image
        );
      } else {
        // Update existing gift
        GiftController().updateGiftDetails(
          id: widget.giftModel!.id,
          name: _giftNameController.text,
          description: _giftDescriptionController.text,
          category: _selectedCategory!,
          price: double.parse(_giftPriceController.text),
          status: 'Available',
          dueDate: DateTime.parse(_dueDateController.text),
          imageBase64: _imageBase64, // Update the image
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          widget.giftModel == null ? 'Wish new Gift! 🎁' : 'Edit Gift',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 20,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: _imageBase64 == null || _imageBase64!.isEmpty
                      ? Image.asset(
                          'assets/images/boxes/gifts.png',
                          height: 240,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              base64Decode(_imageBase64!),
                              height: 200,
                              width: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _requestImagePermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pick an Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _giftNameController,
                  labelText: 'Gift Name',
                  icon: Icons.card_giftcard,
                ),
                CustomTextField(
                  controller: _giftDescriptionController,
                  labelText: 'Gift Description',
                  icon: Icons.description,
                ),
                CustomTextField(
                  controller: _giftPriceController,
                  labelText: 'Gift Price',
                  icon: Icons.attach_money,
                  inputType: TextInputType.number,
                ),
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  onTap: _pickDueDate,
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Colors.deepPurple),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a due date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.giftModel == null ? 'Create Gift' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
