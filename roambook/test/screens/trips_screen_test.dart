import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:roambook/screens/trips_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: [
        quill.FlutterQuillLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets('TripsScreen initial state', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(TripsScreen()));

    // Verify initial UI elements
    expect(find.text('Trip Name'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Select Start Date'), findsOneWidget);
    expect(find.text('Add Trip'), findsOneWidget);
    expect(find.text('Search Trips'), findsOneWidget);
  });

  testWidgets('Add trip with valid data', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(TripsScreen()));

    // Enter trip name
    await tester.enterText(find.byType(TextFormField).first, 'Test Trip');
    await tester.pump();

    // Enter destination
    await tester.enterText(find.byType(TextFormField).last, 'Test Destination');
    await tester.pump();

    // Select date
    await tester.tap(find.text('Select Start Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1')); // Select day 1
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Add trip
    await tester.tap(find.text('Add Trip'));
    await tester.pumpAndSettle();

    // Verify trip was added
    expect(find.text('Test Trip'), findsOneWidget);
    expect(find.text('Test Destination'), findsOneWidget);
  });

  testWidgets('Add trip with invalid data', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(TripsScreen()));

    // Try to add trip without entering data
    await tester.tap(find.text('Add Trip'));
    await tester.pumpAndSettle();

    // Verify error messages
    expect(find.text('Please enter a trip name'), findsOneWidget);
    expect(find.text('Please enter a destination'), findsOneWidget);
  });

  testWidgets('Search trips', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(TripsScreen()));

    // Add a trip
    await tester.enterText(find.byType(TextFormField).first, 'Test Trip');
    await tester.enterText(find.byType(TextFormField).last, 'Test Destination');
    await tester.tap(find.text('Select Start Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Trip'));
    await tester.pumpAndSettle();

    // Search for the trip
    await tester.enterText(find.byType(TextField).last, 'Test');
    await tester.pumpAndSettle();

    // Verify trip is visible
    expect(find.text('Test Trip'), findsOneWidget);

    // Search for non-existent trip
    await tester.enterText(find.byType(TextField).last, 'NonExistent');
    await tester.pumpAndSettle();

    // Verify trip is not visible
    expect(find.text('Test Trip'), findsNothing);
  });

  testWidgets('Navigate to trip entries', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(TripsScreen()));

    // Add a trip
    await tester.enterText(find.byType(TextFormField).first, 'Test Trip');
    await tester.enterText(find.byType(TextFormField).last, 'Test Destination');
    await tester.tap(find.text('Select Start Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Trip'));
    await tester.pumpAndSettle();

    // Tap on the trip
    await tester.tap(find.text('Test Trip'));
    await tester.pumpAndSettle();

    // Verify navigation to entries screen
    expect(find.text('Test Trip'), findsOneWidget); // AppBar title
    expect(find.text('Add Entry'), findsOneWidget);
  });
} 