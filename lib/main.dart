import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gift App',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme:
              AppBarTheme(color: Colors.deepPurple[100], elevation: 30)),
      //theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
