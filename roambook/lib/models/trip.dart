import 'dart:convert';
// Removed: import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:roambook/models/entry.dart';

class Trip {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final List<Entry> entries;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    List<Entry>? entries,
  }) : entries = entries ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      name: json['name'],
      destination: json['destination'],
      startDate: DateTime.parse(json['startDate']),
      entries: (json['entries'] as List?)
          ?.map((e) => Entry.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
// Removed Entry class from this file. 