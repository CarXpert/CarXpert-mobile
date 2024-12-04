import 'package:flutter/material.dart';

class NewsArticleListPage extends StatelessWidget {
  final List<String> authors = ['Author 1', 'Author 2', 'Author 3']; // Replace with dynamic data
  final List<String> categories = ['All Categories', 'Category 1', 'Category 2']; // Replace with dynamic data
  final List<Map<String, dynamic>> articles = [
    {
      'id': 1,
      'title': 'Article 1',
      'author': 'Author 1',
      'category': 'Category 1',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'image': null, // Replace with image URL if available
    },
    {
      'id': 2,
      'title': 'Article 2',
      'author': 'Author 2',
      'category': 'Category 2',
      'content': 'Vivamus lacinia odio vitae vestibulum vestibulum.',
      'image': null,
    },
    // Add more articles
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Automotive News'),
        centerTitle: true,
        backgroundColor: Colors.black,
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
                        value: null,
                        items: authors.map((author) {
                          return DropdownMenuItem(
                            value: author,
                            child: Text(
                              author,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                        value: null,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
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
                        final article = articles[index];
                        return Card(
                          color: Colors.grey[800],
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              article['image'] != null
                                  ? Image.network(
                                      article['image'],
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
