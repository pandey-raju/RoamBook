import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final _locationController = TextEditingController();
  final List<String> _selectedImages = [];
  final _imagePicker = ImagePicker();
  bool _showAddForm = false;

  // Add this getter for testing
  quill.QuillController get quillController => _quillController;

  @override
  void dispose() {
    _quillController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(image.path);
      });
    }
  }

  void _removeImage(String imagePath) {
    setState(() {
      _selectedImages.remove(imagePath);
    });
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
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          images: _selectedImages,
          document: _quillController.document,
          timestamp: DateTime.now(),
        );
        tripProvider.updateEntry(updatedEntry);
        setState(() {
          _editingEntryId = null;
          _locationController.clear();
          _selectedImages.clear();
          _showAddForm = false;
        });
      } else {
        // Add new entry
        final newEntry = Entry(
          tripId: widget.trip.id,
          title: _quillController.document.toPlainText().split('\n').first,
          content: _quillController.document.toPlainText(),
          date: DateTime.now(),
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          images: _selectedImages,
          document: _quillController.document,
          timestamp: DateTime.now(),
        );
        tripProvider.addEntry(newEntry);
        _locationController.clear();
        _selectedImages.clear();
        setState(() {
          _showAddForm = false;
        });
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
      _locationController.text = entry.location ?? '';
      _selectedImages.clear();
      _selectedImages.addAll(entry.images);
      _showAddForm = true;
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
        _locationController.clear();
        _selectedImages.clear();
        _showAddForm = false;
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingEntryId = null;
      _quillController.clear();
      _locationController.clear();
      _selectedImages.clear();
      _showAddForm = false;
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.trip.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.blue],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.trip.destination,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${allEntries.length} entries',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Show search
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search entries...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Add Entry Section
                  if (_showAddForm) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingEntryId != null ? 'Edit Entry' : 'Add New Entry',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Add Photos'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  final imagePath = _selectedImages[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(imagePath),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                              onPressed: () => _removeImage(imagePath),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _addEntry,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(_editingEntryId != null ? 'Update Entry' : 'Add Entry'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _cancelEditing,
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Entries Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Entries (${filteredEntries.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_showAddForm)
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _showAddForm = true;
                            });
                          },
                          backgroundColor: Colors.teal,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Entries List
          if (filteredEntries.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_add,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No entries yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start documenting your journey!',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = filteredEntries[index];
                    return _buildEntryCard(entry);
                  },
                  childCount: filteredEntries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(Entry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (entry.location?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  entry.location!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editEntry(entry.id);
                        } else if (value == 'delete') {
                          _deleteEntry(entry.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      entry.timestamp.toString().split('.')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (entry.images.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entry.images.length,
                itemBuilder: (context, imageIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(entry.images[imageIndex]),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
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