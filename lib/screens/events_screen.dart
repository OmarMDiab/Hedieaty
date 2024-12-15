import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/screens/create_event_screen.dart';
import 'package:hedieaty/widgets/eventCard.dart';
import '../models/user_model.dart';

class EventScreen extends StatefulWidget {
  final UserModel userModel;

  const EventScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final EventController _eventController = EventController();
  String _sortCriterion = 'name'; // Default sorting by name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateEventScreen(userModel: widget.userModel),
              ),
            ),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
            ),
            tooltip: 'Add Event',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortCriterion = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                  value: 'category', child: Text('Sort by Category')),
              const PopupMenuItem(
                  value: 'status', child: Text('Sort by Status')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _eventController.fetchUserEvents(widget.userModel.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var events = snapshot.data!;

            // Sort events based on the selected criterion
            events.sort((a, b) {
              switch (_sortCriterion) {
                case 'category':
                  return a.category.compareTo(b.category);
                case 'status':
                  return _getEventStatus(a).compareTo(_getEventStatus(b));
                case 'name':
                default:
                  return a.name.compareTo(b.name);
              }
            });

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(
                  event: event,
                  onEdit: () => _editEvent(context, event),
                  onDelete: () => _deleteEvent(context, event),
                );
              },
            );
          } else {
            return const Center(child: Text('No events found.'));
          }
        },
      ),
    );
  }

  String _getEventStatus(EventModel event) {
    final now = DateTime.now();
    if (event.date.isAfter(now)) {
      return 'Upcoming';
    } else if (event.date.isBefore(now)) {
      return 'Past';
    } else {
      return 'Current';
    }
  }

  void _editEvent(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          userModel: widget.userModel,
          eventModel: event, // Pass the event to edit
        ),
      ),
    );
  }

  void _deleteEvent(BuildContext context, EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content:
            const Text('Deleting an event will delete associated gift lists!.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set the background color to red
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _eventController.deleteEvent(event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully!')),
      );
    }
  }
}
