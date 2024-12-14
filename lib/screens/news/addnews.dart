import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  String? _selectedImage;

  // Daftar kategori
  final List<String> _categories = [
    'Mobil',
    'Mobil Bekas',
    'Tips and Trick Otomotif',
    'Others',
  ];

  // Fungsi untuk memilih gambar dari assets
  Future<void> _selectImage() async {
    final imageFile = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Daftar gambar di assets/images
              Image.asset('assets/images/car_news.jpg'),
              Image.asset('assets/images/another_car_news.jpg'),
              Image.asset('assets/images/car3.jpg'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('car_news.jpg');
              },
              child: Text('car_news.jpg'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('another_car_news.jpg');
              },
              child: Text('another_car_news.jpg'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('car3.jpg');
              },
              child: Text('car3.jpg'),
            ),
          ],
        );
      },
    );

    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  Future<void> _submitArticle() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/news/api/add/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _selectedCategory,
          'content': _contentController.text,
          'image': _selectedImage, // Tambahkan nama gambar untuk upload
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Article added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['errors']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add article')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Article'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 10),

                // Author Field
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(labelText: 'Author'),
                  validator: (value) => value!.isEmpty ? 'Author is required' : null,
                ),
                SizedBox(height: 10),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) =>
                      value == null ? 'Category is required' : null,
                ),
                SizedBox(height: 10),

                // Content Field
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  validator: (value) => value!.isEmpty ? 'Content is required' : null,
                ),
                SizedBox(height: 20),

                // Image Selector
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Select Image'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
                SizedBox(height: 10),

                // Display Selected Image
                _selectedImage != null
                    ? Image.asset('assets/images/$_selectedImage')
                    : Text('No image selected'),

                SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitArticle,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}