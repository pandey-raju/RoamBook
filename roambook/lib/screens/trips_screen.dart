import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import 'trip_entries_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _addTrip() {
    if (_formKey.currentState!.validate() && _startDate != null) {
      final trip = Trip(
        id: const Uuid().v4(),
        name: _nameController.text,
        destination: _destinationController.text,
        startDate: _startDate!,
      );
      
      context.read<TripProvider>().addTrip(trip);
      
      _nameController.clear();
      _destinationController.clear();
      setState(() {
        _startDate = null;
      });
    }
  }

  void _navigateToTripEntries(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripEntriesScreen(trip: trip),
      ),
    );
  }

  List<Trip> _getFilteredTrips(List<Trip> trips) {
    return trips.where((trip) {
      final name = trip.name.toLowerCase();
      final destination = trip.destination.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || destination.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final filteredTrips = _getFilteredTrips(tripProvider.trips);
        filteredTrips.sort((a, b) => a.startDate.compareTo(b.startDate));

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Trip Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a trip name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _destinationController,
                      decoration: const InputDecoration(labelText: 'Destination'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      title: Text(_startDate == null
                          ? 'Select Start Date'
                          : 'Start Date: ${_startDate!.toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: _addTrip,
                      child: const Text('Add Trip'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Trips',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    final trip = filteredTrips[index];
                    return ListTile(
                      title: Text(trip.name),
                      subtitle: Text('${trip.destination} - ${trip.startDate.toString().split(' ')[0]}'),
                      trailing: Text('${trip.entries.length} entries'),
                      onTap: () => _navigateToTripEntries(trip),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 