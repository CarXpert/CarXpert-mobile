import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
  XFile? _pickedFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Mobil',
    'Mobil Bekas',
    'Tips and Trick Otomotif',
    'Others',
  ];

  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          _selectedImage = path.basename(pickedFile.path);
        });

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        }
      }
    } catch (e) {
      print('Error selecting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _submitArticle() async {
    if (_formKey.currentState!.validate()) {
      try {
        var uri = Uri.parse('https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/news/api/add/');
        var request = http.MultipartRequest('POST', uri);
        request.fields['title'] = _titleController.text;
        request.fields['author'] = _authorController.text;
        request.fields['category'] = _selectedCategory!;
        request.fields['content'] = _contentController.text;

        if (_pickedFile != null) {
          String fileName = path.basename(_pickedFile!.path);
          String extension = path.extension(fileName).toLowerCase();
         
          if (extension.isEmpty) {
            fileName = '$fileName.jpg';
            extension = '.jpg';
          }

          if (kIsWeb) {
            if (_webImage != null) {
              request.files.add(
                http.MultipartFile.fromBytes(
                  'image',
                  _webImage!,
                  filename: fileName,
                  contentType: MediaType('image', extension.substring(1)),
                ),
              );
            }
          } else {
            var file = File(_pickedFile!.path);
            if (await file.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'image',
                  file.path,
                  filename: fileName,
                  contentType: MediaType('image', extension.substring(1)),
                ),
              );
            }
          }
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          var responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            String? imageUrl = responseData['image_url'];
           
            if (imageUrl != null) {
              // Extract just the path portion after media/
              final mediaPath = imageUrl.split('/media/')[1];
             
              // Create a constant base URL string
              const baseUrl = 'https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id';
             
              // Combine into final URL
              final cleanImageUrl = '$baseUrl/media/$mediaPath';
             
              // Store the clean URL for image display
              setState(() {
                _selectedImage = cleanImageUrl;
              });
             
              print('Clean Image URL: $cleanImageUrl');
            }
           
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Article added successfully!')),
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception('Failed to add article. Status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error submitting article: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_pickedFile == null) {
      return Text('No image selected');
    }
   
    try {
      if (kIsWeb) {
        return Container(
          height: 200,
          width: double.infinity,
          child: _webImage != null
              ? Image.memory(
                  _webImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Text('Loading image...'),
        );
      } else {
        return Container(
          height: 200,
          width: double.infinity,
          child: Image.file(
            File(_pickedFile!.path),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image error: $error');
              return Text('Error loading image: $error');
            },
          ),
        );
      }
    } catch (e) {
      print('Caught error: $e');
      return Text('Error displaying image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Article', style: TextStyle(color: Colors.black)),
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
                    "Add New Article",
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

                  // Image Preview
                  if (_pickedFile != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      child: _buildImagePreview(),
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

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitArticle,
                    child: Text('Submit Article'),
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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}