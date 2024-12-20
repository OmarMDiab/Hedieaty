import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class GetNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static void initialize() {
    // Request permissions for iOS
    _firebaseMessaging.requestPermission();

    // Listen for messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showSimpleNotification(
          Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.notification!.title ?? "Notification",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message.notification!.body ?? "",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          background: Colors.blueAccent,
          duration: const Duration(seconds: 3),
          slideDismissDirection: DismissDirection.horizontal,
        );
      }
    });
  }
}
