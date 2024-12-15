import 'package:flutter/material.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/widgets/CustomTextField.dart';
import 'package:hedieaty/models/event_model.dart';

// import 'package:permission_handler/permission_handler.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
class CreateEventScreen extends StatefulWidget {
  final UserModel userModel;
  final EventModel? eventModel;

  const CreateEventScreen(
      {super.key, required this.userModel, this.eventModel});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;

  final List<String> _categories = [
    'Birthday',
    'Wedding',
    'Party',
    'Anniversary'
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _eventDateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.eventModel != null) {
      // If editing, prepopulate the form with event data
      _eventNameController.text = widget.eventModel!.name;
      _eventDescriptionController.text = widget.eventModel!.description;
      _locationController.text = widget.eventModel!.location;
      _eventDateController.text = _formatDate(widget.eventModel!.date);
      _selectedCategory = widget.eventModel!.category;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _pickDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _eventDateController.text =
            selectedDate.toIso8601String().split('T')[0];
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      if (widget.eventModel == null) {
        // Create new event
        EventController().addEvent(
          name: _eventNameController.text,
          description: _eventDescriptionController.text,
          date: DateTime.parse(_eventDateController.text),
          location: _locationController.text,
          category: _selectedCategory!,
          userID: widget.userModel.id,
        );
      } else {
        // Update existing event
        EventController().updateEvent(
          eventID: widget.eventModel!.id,
          name: _eventNameController.text,
          description: _eventDescriptionController.text,
          date: DateTime.parse(_eventDateController.text),
          location: _locationController.text,
          category: _selectedCategory!,
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
          widget.eventModel == null ? 'Create New Event 🎉' : 'Edit Event',
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
                  child: Image.asset(
                    'assets/images/boxes/event2.png',
                    height: 240,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _eventNameController,
                  labelText: 'Event Name',
                  icon: Icons.note,
                ),
                CustomTextField(
                  controller: _eventDescriptionController,
                  labelText: 'Event Description',
                  icon: Icons.description,
                ),
                CustomTextField(
                  controller: _locationController,
                  labelText: 'Location',
                  icon: Icons.location_on_outlined,
                ),
                TextFormField(
                  controller: _eventDateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: 'Event Date',
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
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Colors.deepPurple),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.eventModel == null ? 'Create Event' : 'Save Changes',
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
