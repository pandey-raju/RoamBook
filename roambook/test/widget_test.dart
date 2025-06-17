// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roambook/main.dart';

void main() {
  testWidgets('Trips screen is shown by default', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoamBookApp());

    // Verify that the Trips screen placeholder text is present.
    expect(find.text('Trips will be listed here'), findsNothing);
    expect(find.text('Settings will be available here'), findsNothing);
  });

  testWidgets('Add a new trip', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoamBookApp());

    // Enter trip name
    await tester.enterText(find.byType(TextFormField).first, 'Summer Vacation');
    await tester.pump();

    // Enter destination
    await tester.enterText(find.byType(TextFormField).last, 'Paris');
    await tester.pump();

    // Tap on the date picker
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    // Select a date (e.g., first day of the month)
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Tap the Add Trip button
    await tester.tap(find.text('Add Trip'));
    await tester.pumpAndSettle();

    // Verify that the new trip is added to the list
    expect(find.text('Summer Vacation'), findsOneWidget);
    expect(find.textContaining('Paris -'), findsOneWidget);
  });
}
