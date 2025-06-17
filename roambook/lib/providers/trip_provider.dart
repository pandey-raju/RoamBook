import 'package:flutter/foundation.dart';
import 'package:roambook/models/trip.dart';
import 'package:roambook/models/entry.dart';

class TripProvider with ChangeNotifier {
  final List<Trip> _trips = [];
  final Map<String, List<Entry>> _entries = {};

  List<Trip> get trips => List.unmodifiable(_trips);

  List<Entry> getEntriesForTrip(String tripId) {
    return List.unmodifiable(_entries[tripId] ?? []);
  }

  void addTrip(Trip trip) {
    _trips.add(trip);
    _entries[trip.id] = [];
    notifyListeners();
  }

  void updateTrip(Trip trip) {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      _trips[index] = trip;
      notifyListeners();
    }
  }

  void deleteTrip(String id) {
    _trips.removeWhere((trip) => trip.id == id);
    _entries.remove(id);
    notifyListeners();
  }

  Trip? getTrip(String id) {
    try {
      return _trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addEntry(Entry entry) async {
    if (!_entries.containsKey(entry.tripId)) {
      _entries[entry.tripId] = [];
    }
    _entries[entry.tripId]!.add(entry);
    notifyListeners();
  }

  Future<void> updateEntry(Entry entry) async {
    if (_entries.containsKey(entry.tripId)) {
      final index = _entries[entry.tripId]!.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[entry.tripId]![index] = entry;
        notifyListeners();
      }
    }
  }

  Future<void> deleteEntry(String entryId) async {
    for (final entries in _entries.values) {
      entries.removeWhere((entry) => entry.id == entryId);
    }
    notifyListeners();
  }
} 