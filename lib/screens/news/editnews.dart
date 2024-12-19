import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
  XFile? _pickedFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

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

  Widget _buildImagePreview() {
    if (_pickedFile != null) {
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
    } else if (_selectedImage != null) {
      return Container(
        height: 200,
        width: double.infinity,
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
      );
    } else {
      return Text('No image selected');
    }
  }

  Future<void> _updateArticle() async {
    if (_formKey.currentState!.validate()) {
      try {
        final articleId = widget.article['pk'];
        var uri = Uri.parse('http://127.0.0.1:8000/news/api/$articleId/edit/');
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

        print('Sending request...');
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            if (responseData['image_url'] != null) {
              setState(() {
                _selectedImage = responseData['image_url'].split('/media/')[1];
              });
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Article updated successfully!')),
            );
            Navigator.pop(context);
          } else {
            throw Exception('Update failed: ${responseData['errors']}');
          }
        } else {
          throw Exception('Failed to update article. Status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error updating article: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

                  _buildImagePreview(),
                  SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _selectImage,
                    icon: Icon(Icons.image),
                    label: Text('Select New Image'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20),

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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}