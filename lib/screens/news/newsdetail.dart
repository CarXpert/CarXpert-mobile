import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    final fields = article['fields'];
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Hero image with gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF0F0F3D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Hero Section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: mediaQuery.size.height * 0.4,
                    child: fields['image'] != null
                        ? Image.network(
                            'http://127.0.0.1:8000' + fields['image'],
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[700],
                            child: Center(
                              child: Icon(Icons.image, color: Colors.white, size: 50),
                            ),
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    height: mediaQuery.size.height * 0.4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top + 8,
                    left: 8,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        fields['title'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Author and Category
                      Text(
                        '${fields['author']} • ${fields['category']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Content
                      Text(
                        fields['content'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Footer with tags or additional info (optional)
                      if (fields['tags'] != null && fields['tags'].isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: (fields['tags'] as List<dynamic>)
                              .map((tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.blueGrey,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
