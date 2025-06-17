import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class Entry {
  final String id;
  final String tripId;
  final String title;
  final String content;
  final DateTime date;
  final String? location;
  final List<String> images;
  final List<String> tags;
  final quill.Document document;
  final DateTime timestamp;

  Entry({
    String? id,
    required this.tripId,
    required this.title,
    required this.content,
    required this.date,
    this.location,
    List<String>? images,
    List<String>? tags,
    required this.document,
    required this.timestamp,
  })  : id = id ?? const Uuid().v4(),
        images = images ?? [],
        tags = tags ?? [];

  Entry copyWith({
    String? id,
    String? tripId,
    String? title,
    String? content,
    DateTime? date,
    String? location,
    List<String>? images,
    List<String>? tags,
    quill.Document? document,
    DateTime? timestamp,
  }) {
    return Entry(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      location: location ?? this.location,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      document: document ?? this.document,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'location': location,
      'images': images,
      'tags': tags,
      'document': document.toPlainText(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    final document = quill.Document();
    try {
      document.insert(0, json['document'] as String);
    } catch (e) {
      // If there's an error, create a new document with the content
      document.insert(0, json['content'] as String);
    }

    return Entry(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      document: document,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
} 