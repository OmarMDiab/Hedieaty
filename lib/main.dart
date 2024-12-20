import 'package:flutter/material.dart';
//import 'package:hedieaty/services/sqlite_helper.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:overlay_support/overlay_support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for iOS
  if (Platform.isIOS) {
    await messaging.requestPermission();
  }
  //await SQLiteHelper().deleteDatabaseFile();
  runApp(
    const OverlaySupport.global(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gift App',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(
                color: Colors.white, // Set back button color to white globally
              ),
              backgroundColor: Color.fromARGB(255, 67, 25, 184),
              elevation: 30)),
      //theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
