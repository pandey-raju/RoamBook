import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/trip.dart';
import '../models/entry.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';

class TripEntriesScreen extends StatefulWidget {
  final Trip trip;

  const TripEntriesScreen({super.key, required this.trip});

  @override
  State<TripEntriesScreen> createState() => _TripEntriesScreenState();
}

class _TripEntriesScreenState extends State<TripEntriesScreen> {
  final quill.QuillController _quillController = quill.QuillController.basic();
  String _searchQuery = '';
  String? _editingEntryId;

  // Add this getter for testing
  quill.QuillController get quillController => _quillController;

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (!_quillController.document.isEmpty()) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      if (_editingEntryId != null) {
        // Update existing entry
        final allEntries = tripProvider.getEntriesForTrip(widget.trip.id);
        final entryToUpdate = allEntries.firstWhere((e) => e.id == _editingEntryId);
        final updatedEntry = Entry(
          id: entryToUpdate.id,
          tripId: widget.trip.id,
          title: _quillController.document.toPlainText().split('\n').first,
          content: _quillController.document.toPlainText(),
          date: DateTime.now(),
          document: _quillController.document,
          timestamp: DateTime.now(),
        );
        tripProvider.updateEntry(updatedEntry);
        setState(() {
          _editingEntryId = null;
        });
      } else {
        // Add new entry
        final newEntry = Entry(
          tripId: widget.trip.id,
          title: _quillController.document.toPlainText().split('\n').first,
          content: _quillController.document.toPlainText(),
          date: DateTime.now(),
          document: _quillController.document,
          timestamp: DateTime.now(),
        );
        tripProvider.addEntry(newEntry);
      }
      _quillController.clear();
    }
  }

  void _editEntry(String entryId) {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final allEntries = tripProvider.getEntriesForTrip(widget.trip.id);
    final entry = allEntries.firstWhere((e) => e.id == entryId);
    
    // Create a new document with the entry's content
    final newDocument = quill.Document();
    newDocument.insert(0, entry.content);
    
    setState(() {
      _editingEntryId = entryId;
      _quillController.document = newDocument;
      _quillController.updateSelection(
        const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.local
      );
    });
  }

  void _deleteEntry(String entryId) {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.deleteEntry(entryId);
    setState(() {
      if (_editingEntryId == entryId) {
        _editingEntryId = null;
        _quillController.clear();
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingEntryId = null;
      _quillController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    final allEntries = tripProvider.getEntriesForTrip(widget.trip.id);
    final filteredEntries = allEntries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final title = entry.title.toLowerCase();
      final content = entry.content.toLowerCase();
      final location = (entry.location ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || 
             content.contains(query) || 
             location.contains(query);
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by oldest first

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.trip.destination.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      widget.trip.destination,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: quill.QuillEditor.basic(
                    controller: _quillController,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _addEntry,
                      child: Text(_editingEntryId != null ? 'Update Entry' : 'Add Entry'),
                    ),
                    if (_editingEntryId != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _cancelEditing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Entries',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty 
                          ? 'No entries yet' 
                          : 'No entries found for "$_searchQuery"',
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(entry.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (entry.location?.isNotEmpty ?? false)
                                Text(entry.location!),
                              Text(
                                entry.timestamp.toString().split('.')[0],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editEntry(entry.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteEntry(entry.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 