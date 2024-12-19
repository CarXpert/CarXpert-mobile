import 'dart:convert';

import 'package:car_xpert/screens/detailcar/detailcar.dart';
import 'package:flutter/material.dart';
import 'package:car_xpert/models/wishlist_item.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:car_xpert/screens/wishlist/editnote.dart';  

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<WishlistItem> wishlist = [];

  Future<List<WishlistItem>> fetchWishlist(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/wishlist/json/');

    // Decode and parse data
    var data = response;
    List<WishlistItem> listWishlist = [];
    for (var d in data) {
      if (d != null) {
        listWishlist.add(WishlistItem.fromJson(d));
      }
    }
    return listWishlist;
  }

  Future<void> deleteWishlistItem(String itemId, CookieRequest request) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/wishlist/remove/',
        {'car_id': itemId},
      );

      // Check if the response status is success
      if (response['status'] == 'success') {
        setState(() {
          wishlist.removeWhere((item) => item.car.carId == itemId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Item removed successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: ${response['message']}')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }


  void _confirmRemoveItem(BuildContext context, String itemId, CookieRequest request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text("Are you sure you want to remove this item from your wishlist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await deleteWishlistItem(itemId, request); // Remove and update UI
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.blue, // Light theme color
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3F4F6), Color(0xFFDBE2E7)], // Light gradient for a light theme
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<WishlistItem>>(
          future: fetchWishlist(request),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No items in your wishlist.'));
            }

            wishlist = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final item = wishlist[index];
                return Card(
                  color: Colors.white, // Light card color
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Image.asset(
                            'assets/images/${item.car.brand}.png',
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Car Brand and Type
                        Text(
                          '${item.car.brand} - ${item.car.carType}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Showroom Name
                        Text(
                          item.car.showroom,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        // Notes
                        Text(
                          item.notes ?? 'No notes yet',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tooltip(
                              message: 'Remove from Wishlist',
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Show confirmation dialog before removing item
                                  _confirmRemoveItem(context, item.car.carId, request);
                                },
                              ),
                            ),
                            Tooltip(
                              message: 'Edit Note',
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  // Navigate to EditNotePage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditNotePage(item: item),
                                    ),
                                  );
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailCarPage(carId: item.car.carId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Light button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text('Car Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
