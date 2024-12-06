import 'dart:convert';
import 'package:car_xpert/screens/news/addnews.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsArticleListPage extends StatefulWidget {
  @override
  _NewsArticleListPageState createState() => _NewsArticleListPageState();
}

class _NewsArticleListPageState extends State<NewsArticleListPage> {
  List<dynamic> articles = [];
  List<String> authors = [];
  List<String> categories = ['All Categories'];
  String? selectedAuthor;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/news/json/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      setState(() {
        articles = data;
        authors = data.map((article) => article['fields']['author'] as String).toSet().toList();
        authors.insert(0, 'All Authors');
        categories = data.map((article) => article['fields']['category'] as String).toSet().toList();
        categories.insert(0, 'All Categories');
      });
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<void> deleteArticle(int id) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/news/api/$id/delete/'),
    );
    if (response.statusCode == 200) {
      fetchArticles(); // Refresh articles after deletion
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete article')));
    }
  }

  void navigateToAddArticle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddArticlePage(), // Create this page separately
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Automotive News'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddArticle,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        tooltip: 'Add Article',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0F0F3D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Filter Section
              Card(
                color: Colors.white.withOpacity(0.1),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Author',
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                        value: selectedAuthor,
                        items: authors.map((author) {
                          return DropdownMenuItem(
                            value: author,
                            child: Text(
                              author,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAuthor = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                        value: selectedCategory,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchArticles,
                        child: Text('Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Articles Grid
              articles.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index]['fields'];
                        final articleId = articles[index]['pk'];
                        return Card(
                          color: Colors.grey[800],
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              article['image'] != null
                                  ? Image.network(
                                      'http://127.0.0.1:8000' + article['image'],
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 120,
                                      color: Colors.grey[700],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Published by ${article['author']} | ${article['category']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      article['content'],
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Navigate to edit page
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deleteArticle(articleId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "Sorry, we don't have any news yet.",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
