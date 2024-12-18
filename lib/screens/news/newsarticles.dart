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
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/news/json/'));
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
  }

  Future<void> deleteArticle(int articleId) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/news/api/$articleId/delete/'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article deleted successfully!')),
      );
      fetchArticles(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete article')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Automotive News', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: 
      isAdmin 
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0F0F3D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Author',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      value: selectedAuthor,
                      items: authors.map((author) {
                        return DropdownMenuItem(
                          value: author,
                          child: Text(author, style: TextStyle(color: Colors.white)),
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
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category, style: TextStyle(color: Colors.white)),
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
              ),
            ),
            Expanded(
              child: filteredArticles.isNotEmpty
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: isAdmin ? 0.9 : 0.8,
                      ),
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index]['fields'];
                        final articleId = filteredArticles[index]['pk'];
                        return 
                        InkWell(
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
                            color: Colors.grey[850],
                            elevation: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: article['image'] != null
                                      ? Image.network(
                                          'http://127.0.0.1:8000' + article['image'],
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 120,
                                          color: Colors.grey[700],
                                          child: Icon(Icons.image, color: Colors.white),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article['title'],
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${article['author']} | ${article['category']}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        article['content'],
                                        style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAdmin)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}