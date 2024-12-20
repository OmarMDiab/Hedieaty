import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/screens/create_event_screen.dart';
import 'package:hedieaty/screens/gifts_screen.dart';
import 'package:hedieaty/widgets/eventCard.dart';
import '../models/user_model.dart';

class EventScreen extends StatefulWidget {
  final UserModel userModel;
  final bool isOwner;

  const EventScreen({super.key, required this.userModel, this.isOwner = true});

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
          if (widget.isOwner)
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
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortCriterion = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                  value: 'category', child: Text('Sort by Category')),
              const PopupMenuItem(value: 'status', child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.purple,
                  Color.fromARGB(255, 90, 15, 103)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          StreamBuilder<List<EventModel>>(
            stream: _eventController.fetchUserEvents(widget.userModel.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No events found.',
                        style: TextStyle(color: Colors.black)));
              } else {
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftScreen(
                              eventModel: event,
                              userModel: widget.userModel,
                              isOwner: widget.isOwner,
                            ),
                          ),
                        );
                      },
                      child: EventCard(
                        event: event,
                        onEdit: widget.isOwner
                            ? () => _editEvent(context, event)
                            : null,
                        onDelete: widget.isOwner
                            ? () => _deleteEvent(context, event)
                            : null,
                        onPublish: widget.isOwner && event.isPublished == false
                            ? () => _publishEvent(context, event)
                            : null,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
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
            const Text('Deleting an event will delete associated gift lists!'),
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

  void _publishEvent(BuildContext context, EventModel event) async {
    await _eventController.publishEvent(event.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!')),
    );
  }
}
