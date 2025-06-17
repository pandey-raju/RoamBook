import 'package:flutter/material.dart';

void main() {
  runApp(const RoamBookApp());
}

class RoamBookApp extends StatelessWidget {
  const RoamBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoamBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    TripsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoamBook'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final List<Map<String, dynamic>> _trips = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  String _searchQuery = '';

  void _addTrip() {
    if (_formKey.currentState!.validate() && _startDate != null) {
      setState(() {
        _trips.add({
          'name': _nameController.text,
          'destination': _destinationController.text,
          'startDate': _startDate,
          'entries': <Map<String, dynamic>>[],
        });
        _nameController.clear();
        _destinationController.clear();
        _startDate = null;
      });
    }
  }

  void _navigateToTripEntries(int tripIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripEntriesScreen(trip: _trips[tripIndex]),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTrips() {
    return _trips.where((trip) {
      final name = trip['name'].toString().toLowerCase();
      final destination = trip['destination'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || destination.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = _getFilteredTrips();
    filteredTrips.sort((a, b) => (a['startDate'] as DateTime).compareTo(b['startDate'] as DateTime));

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
                  title: Text(trip['name']),
                  subtitle: Text('${trip['destination']} - ${trip['startDate'].toString().split(' ')[0]}'),
                  trailing: Text('${trip['entries'].length} entries'),
                  onTap: () => _navigateToTripEntries(_trips.indexOf(trip)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TripEntriesScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripEntriesScreen({super.key, required this.trip});

  @override
  State<TripEntriesScreen> createState() => _TripEntriesScreenState();
}

class _TripEntriesScreenState extends State<TripEntriesScreen> {
  final _entryController = TextEditingController();

  void _addEntry() {
    if (_entryController.text.isNotEmpty) {
      setState(() {
        widget.trip['entries'].add({
          'text': _entryController.text,
          'timestamp': DateTime.now(),
        });
        _entryController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _entryController,
              decoration: const InputDecoration(
                labelText: 'New Entry',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: null,
                ),
              ),
              onSubmitted: (_) => _addEntry(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.trip['entries'].length,
                itemBuilder: (context, index) {
                  final entry = widget.trip['entries'][index];
                  return ListTile(
                    title: Text(entry['text']),
                    subtitle: Text(entry['timestamp'].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings will be available here',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
