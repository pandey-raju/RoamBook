import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:roambook/models/trip.dart';

void main() {
  group('Trip Model Tests', () {
    test('Trip creation with required fields', () {
      final trip = Trip(
        name: 'Test Trip',
        destination: 'Test Destination',
        startDate: DateTime(2024, 1, 1),
      );

      expect(trip.name, 'Test Trip');
      expect(trip.destination, 'Test Destination');
      expect(trip.startDate, DateTime(2024, 1, 1));
      expect(trip.entries, isEmpty);
    });

    test('Trip creation with entries', () {
      final entries = [
        Entry(
          document: quill.Document(),
          timestamp: DateTime(2024, 1, 1),
        ),
      ];

      final trip = Trip(
        name: 'Test Trip',
        destination: 'Test Destination',
        startDate: DateTime(2024, 1, 1),
        entries: entries,
      );

      expect(trip.entries.length, 1);
      expect(trip.entries.first.timestamp, DateTime(2024, 1, 1));
    });

    test('Trip toJson and fromJson', () {
      final originalTrip = Trip(
        name: 'Test Trip',
        destination: 'Test Destination',
        startDate: DateTime(2024, 1, 1),
        entries: [
          Entry(
            document: quill.Document(),
            timestamp: DateTime(2024, 1, 1),
          ),
        ],
      );

      final json = originalTrip.toJson();
      final restoredTrip = Trip.fromJson(json);

      expect(restoredTrip.name, originalTrip.name);
      expect(restoredTrip.destination, originalTrip.destination);
      expect(restoredTrip.startDate, originalTrip.startDate);
      expect(restoredTrip.entries.length, originalTrip.entries.length);
      expect(restoredTrip.entries.first.timestamp, originalTrip.entries.first.timestamp);
    });
  });

  group('Entry Model Tests', () {
    test('Entry creation', () {
      final document = quill.Document();
      final timestamp = DateTime(2024, 1, 1);
      final entry = Entry(
        document: document,
        timestamp: timestamp,
      );

      expect(entry.document, document);
      expect(entry.timestamp, timestamp);
    });

    test('Entry toJson and fromJson', () {
      final document = quill.Document();
      final timestamp = DateTime(2024, 1, 1);
      final originalEntry = Entry(
        document: document,
        timestamp: timestamp,
      );

      final json = originalEntry.toJson();
      final restoredEntry = Entry.fromJson(json);

      expect(restoredEntry.timestamp, originalEntry.timestamp);
      // Note: We can't directly compare documents as they might have different internal states
      // Instead, we can compare their JSON representations
      expect(
        restoredEntry.document.toDelta().toJson(),
        originalEntry.document.toDelta().toJson(),
      );
    });
  });
} 