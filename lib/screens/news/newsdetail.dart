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
          // Background color
          Positioned.fill(
            child: Container(
              color: Colors.white,
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
                            'https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/media/${fields['image']}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.image, 
                                    color: Colors.grey[400], 
                                    size: 50
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.image, 
                                color: Colors.grey[400], 
                                size: 50
                              ),
                            ),
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    height: mediaQuery.size.height * 0.4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top + 8,
                    left: 8,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        width: double.infinity,
                        child: Text(
                          fields['title'],
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Author and Category
                      Container(
                        width: double.infinity,
                        child: Text(
                          '${fields['author']} • ${fields['category']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Yellow Divider
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.yellow[700],
                      ),
                      SizedBox(height: 24),
                      // Content
                      Container(
                        width: double.infinity,
                        child: Text(
                          fields['content'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.8,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 32),
                      // Footer with tags or additional info (optional)
                      if (fields['tags'] != null && fields['tags'].isNotEmpty)
                        Container(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: (fields['tags'] as List<dynamic>)
                                .map((tag) => Chip(
                                      label: Text(
                                        tag,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      backgroundColor: Colors.yellow[100],
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    ))
                                .toList(),
                          ),
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