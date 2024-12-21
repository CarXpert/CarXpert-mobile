import 'dart:convert';
import 'package:car_xpert/screens/news/addnews.dart';
import 'package:car_xpert/screens/news/editnews.dart';
import 'package:car_xpert/screens/news/newsdetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  List<dynamic> filteredArticles = [];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
    fetchArticles();
  }

  Future<void> checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('is_admin') ?? false;
    });
  }

  Future<void> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse('https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/news/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          articles = data;
          authors = data.map((article) => article['fields']['author'] as String).toSet().toList();
          authors.insert(0, 'All Authors');
          categories = data.map((article) => article['fields']['category'] as String).toSet().toList();
          categories.insert(0, 'All Categories');
          filteredArticles = articles;
        });
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      print('Error fetching articles: $e');
    }
  }

  Future<void> deleteArticle(int articleId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/news/api/$articleId/delete/'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article deleted successfully!')),
        );
        fetchArticles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete article')),
        );
      }
    } catch (e) {
      print('Error deleting article: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting article: $e')),
      );
    }
  }

  void filterArticles() {
    setState(() {
      filteredArticles = articles.where((article) {
        final fields = article['fields'];
        bool authorMatches = selectedAuthor == null || selectedAuthor == 'All Authors' || fields['author'] == selectedAuthor;
        bool categoryMatches = selectedCategory == null || selectedCategory == 'All Categories' || fields['category'] == selectedCategory;
        return authorMatches && categoryMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine grid layout
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Automotive News', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: isAdmin 
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddArticlePage(),
                ),
              ).then((_) => fetchArticles());
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
            tooltip: 'Add Article',
          )
        : null,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    "What's New?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 3,
                    color: Colors.yellow[700],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth > 600 ? 
                          (constraints.maxWidth - 10) / 2 : 
                          constraints.maxWidth,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Author',
                            labelStyle: TextStyle(color: Colors.black87),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          value: selectedAuthor,
                          isExpanded: true,
                          dropdownColor: Colors.grey[200],
                          items: authors.map((author) {
                            return DropdownMenuItem(
                              value: author,
                              child: Text(
                                author,
                                style: TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAuthor = value;
                              filterArticles();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 600 ? 
                          (constraints.maxWidth - 10) / 2 : 
                          constraints.maxWidth,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Colors.black87),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          value: selectedCategory,
                          isExpanded: true,
                          dropdownColor: Colors.grey[200],
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              filterArticles();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: filteredArticles.isNotEmpty
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: isAdmin ? 0.75 : 0.85,
                      ),
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index]['fields'];
                        final articleId = filteredArticles[index]['pk'];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailPage(article: filteredArticles[index]),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: article['image'] != null
                                        ? Image.network(
                                            'https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/media/${article['image']}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image: $error');
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(Icons.image, color: Colors.grey[400]),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: Icon(Icons.image, color: Colors.grey[400]),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${article['author']} | ${article['category']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Flexible(
                                          child: Text(
                                            article['content'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditArticlePage(
                                                  article: filteredArticles[index]
                                                ),
                                              ),
                                            ).then((_) => fetchArticles());
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirm Delete'),
                                                content: Text('Are you sure you want to delete this article?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteArticle(articleId);
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No articles match your filters.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}