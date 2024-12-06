import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/screens/home_screen.dart';
import 'package:hedieaty/screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gift App',
      theme: ThemeData(primarySwatch: Colors.blue,appBarTheme: AppBarTheme(color: Colors.deepPurple[100],elevation: 30)),
      //theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
