import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Login and Add Friend Test', () {
    testWidgets('Login with valid credentials and add a friend by phone number',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login
      print('Filling in email and password...');
      await tester.enterText(
          find.byKey(const Key('emailField')), 'tester1@gmail.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), '12345678');

      //debugDumpApp();
      print('Filling complete, now tapping login...');
      await tester.pumpAndSettle(); // Ensure all animations are complete
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(); // Wait for any UI updates and navigation
      print('Login tapped, waiting for response...');

      // Verify login success
      expect(find.textContaining('Welcome'), findsOneWidget);
      print("Login successful!");

      // Step 2: Add a friend
      await tester.pumpAndSettle(); // Wait for any UI updates

      await Future.delayed(const Duration(seconds: 4));
      final addFriendButton = find.byKey(Key('addFriendFloatingButton'));
      expect(
          addFriendButton, findsOneWidget); // Make sure it's in the widget tree

      await tester.tap(addFriendButton);
      print('Add friend button tapped...');

      // Verify if the dialog appeared
      expect(find.byKey(const Key('friendPhoneField')), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('friendPhoneField')), '0123456789');
      await tester.tap(find.byKey(const Key('addFriendButton')));
      await tester.pumpAndSettle();

      // Verify friend was added
      expect(find.text('0123456789'), findsOneWidget);
    });
  });
}
