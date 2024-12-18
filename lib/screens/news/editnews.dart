import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditArticlePage extends StatefulWidget {
  final dynamic article;

  EditArticlePage({required this.article});

  @override
  _EditArticlePageState createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _contentController;
  String? _selectedCategory;
  String? _selectedImage;

  // Daftar kategori
  final List<String> _categories = [
    'Mobil',
    'Mobil Bekas',
    'Tips and Trick Otomotif',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    final fields = widget.article['fields'];
    _titleController = TextEditingController(text: fields['title']);
    _authorController = TextEditingController(text: fields['author']);
    _contentController = TextEditingController(text: fields['content']);
    _selectedCategory = fields['category'];
    _selectedImage = fields['image'] != null 
      ? fields['image'].split('/').last 
      : null;
  }


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

  Future<void> _updateArticle() async {
    if (_formKey.currentState!.validate()) {
      final articleId = widget.article['pk'];
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/news/api/$articleId/edit/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _selectedCategory,
          'content': _contentController.text,
          'image': _selectedImage,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Article updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['errors']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update article')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Article'),
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
                  onPressed: _updateArticle,
                  child: Text('Update'),
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