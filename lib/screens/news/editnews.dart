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
    _selectedImage = fields['image'];
  }

  Future<void> _selectImage() async {
    // Since we're working with server images, we'll just show available options
    final imageFile = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [],
            ),
          ),
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
        title: Text('Edit Article', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Your Article",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 3,
                    color: Colors.yellow[700],
                    margin: EdgeInsets.only(top: 8, bottom: 20),
                  ),
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) => value!.isEmpty ? 'Title is required' : null,
                  ),
                  SizedBox(height: 16),

                  // Author Field
                  TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) => value!.isEmpty ? 'Author is required' : null,
                  ),
                  SizedBox(height: 16),

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
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) => value == null ? 'Category is required' : null,
                  ),
                  SizedBox(height: 16),

                  // Content Field
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 5,
                    validator: (value) => value!.isEmpty ? 'Content is required' : null,
                  ),
                  SizedBox(height: 20),

                  // Image Display
                  if (_selectedImage != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Image.network(
                        'http://127.0.0.1:8000/media/$_selectedImage',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),

                  // Image Selector Button
                  ElevatedButton.icon(
                    onPressed: _selectImage,
                    icon: Icon(Icons.image),
                    label: Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Update Button
                  ElevatedButton(
                    onPressed: _updateArticle,
                    child: Text('Update Article'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}