import 'package:flutter/material.dart';
import 'package:car_xpert/models/wishlist_item.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditNotePage extends StatefulWidget {
  final WishlistItem item;

  const EditNotePage({super.key, required this.item});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current note
    _noteController.text = widget.item.notes ?? '';
  }

  Future<void> saveNoteToBackend(CookieRequest request) async {
    final carId = widget.item.car.carId.toString();
    final note = _noteController.text;
    
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/wishlist/edit-note-api/',
        {'car_id': carId, 'note': note},
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Note updated successfully.')),
        );
        Navigator.pop(context, note); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update note: ${response['message']}')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e'))      
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note for ${widget.item.car.brand}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF0f0f3d), Color(0xFF1b1b5c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display car image
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(
                'assets/images/${widget.item.car.brand}.png',
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Text field for editing the note
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your note here...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Buttons to save or go back
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await saveNoteToBackend(request);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('Save Note'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back without saving
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
