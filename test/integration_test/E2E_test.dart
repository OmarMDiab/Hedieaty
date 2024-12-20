import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login and Add Friend Test', () {
    testWidgets('Login with valid credentials and add a friend by phone number',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login
      // Enter email
      await tester.enterText(
          find.byKey(const Key('emailField')), 'tester1@gmail.com');
      // Enter password
      await tester.enterText(
          find.byKey(const Key('passwordField')), '12345678');
      // Tap login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify login success
      expect(find.textContaining('Welcome'), findsOneWidget);

      // Step 2: Add a friend
      // Tap on the add friend button
      await tester.tap(find.byTooltip('Add Friend'));
      await tester.pumpAndSettle();

      // Enter the friend's phone number
      await tester.enterText(
          find.byKey(const Key('friendPhoneField')), '0123456789');
      // Tap the add friend button in the dialog
      await tester.tap(find.byKey(const Key('addFriendButton')));
      await tester.pumpAndSettle();

      expect(find.text('0123456789'), findsOneWidget);
    });
  });
}
