import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

// E2E test for the login and add friend functionality in integration_test

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('End-to-End Test: Login and Add Friend', () {
    // Test 1: Login
    testWidgets('Login Test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(); // Wait for the app to settle

      // Step 1: Login
      print('Filling in email and password...');
      await tester.enterText(
          find.byKey(const Key('emailField')), 'tester1@gmail.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), '12345678');
      print('Email and password filled, now tapping login...');
      // Close the keyboard by sending a close command to the text input system
      await SystemChannels.textInput.invokeMethod('TextInput.hide');

      await tester.pumpAndSettle(
          const Duration(seconds: 8)); // Wait for UI updates and navigation
      // tap the close button of the phone

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(
          const Duration(seconds: 30)); // Wait for UI updates and navigation

      // Verify login success
      // Step 2: Navigate to HomeScreen and ensure user is logged in
      await tester.pumpAndSettle(); // Wait for the home screen to load

      // Verify that the HomeScreen is loaded
      expect(find.textContaining('Welcome'), findsOneWidget);
      print('Login successful!');
    });

    // Test 2: login then ---> Add Friend
    testWidgets('Login then Add a friend by phone number',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(); // Wait for the app to settle

      // Step 1: Login (as it was part of the Add Friend test)
      print('Filling in email and password...');
      await tester.enterText(
          find.byKey(const Key('emailField')), 'tester1@gmail.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), '12345678');
      print('Email and password filled, now tapping login...');
      // Close the keyboard by sending a close command to the text input system
      await SystemChannels.textInput.invokeMethod('TextInput.hide');

      await tester.pumpAndSettle(
          const Duration(seconds: 8)); // Wait for UI updates and navigation
      // tap the close button of the phone

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(
          const Duration(seconds: 30)); // Wait for UI updates and navigation

      // Verify login success
      await tester.pumpAndSettle(); // Wait for the home screen to load
      expect(find.textContaining('Welcome'), findsOneWidget);
      print('Login successful!');

      // Step 2: Add Friend
      // Tap the add friend button
      final addFriendButton = find.byKey(const Key('addFriendFloatingButton'));
      expect(addFriendButton, findsOneWidget); // Ensure the button is visible
      await tester.tap(addFriendButton);
      await tester.pumpAndSettle(); // Wait for the dialog to appear

      // Verify that the dialog appears and phone number field is present
      expect(find.byKey(const Key('friendPhoneField')), findsOneWidget);
      print('Add friend dialog appeared.');

      // Step 3: Enter friend's phone number
      await tester.enterText(
          find.byKey(const Key('friendPhoneField')), '0123456789');
      print('Friend\'s phone number entered.');
      await SystemChannels.textInput.invokeMethod('TextInput.hide');

      // Tap the "Add Friend" button in the dialog
      await tester.tap(find.byKey(const Key('addFriendButton')));
      await tester.pumpAndSettle(
          const Duration(seconds: 10)); // Wait for the operation to complete

      // Verify that the phone number appears in the friends list
      expect(find.text('0123456789'), findsOneWidget);
      print('Friend added successfully!');
    });
  });
}
