import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:car_xpert/models/wishlist_item.dart';
import 'package:car_xpert/screens/detailcar/detailcar.dart';
import 'package:car_xpert/screens/wishlist/editnote.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<WishlistItem> wishlist = [];
  String sortOrder = "Newest Added";

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    fetchWishlist(request, sortOrder);
  }

  Future<List<WishlistItem>> fetchWishlist(CookieRequest request, String sortOrder) async {
    final response = await request.get('http://127.0.0.1:8000/wishlist/json/');
    var data = response;

    List<WishlistItem> listWishlist = [];
    for (var d in data) {
      if (d != null) {
        listWishlist.add(WishlistItem.fromJson(d));
      }
    }

    if (sortOrder == "Newest Added") {
      listWishlist.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortOrder == "Oldest Added") {
      listWishlist.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return listWishlist;
  }

  Future<void> deleteWishlistItem(String itemId, CookieRequest request) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/wishlist/remove/',
        {'car_id': itemId},
      );

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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await deleteWishlistItem(itemId, request);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(25),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: sortOrder,
                  onChanged: (String? newValue) {
                    setState(() {
                      sortOrder = newValue!;
                    });
                  },
                  items: <String>['Newest Added', 'Oldest Added']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<WishlistItem>>(
              future: fetchWishlist(request, sortOrder),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65, // Rasio tinggi-lebar disesuaikan
                    ),
                    itemCount: wishlist.length,
                    itemBuilder: (context, index) {
                      final item = wishlist[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            Expanded(
                              flex: 6, // Berikan lebih banyak ruang untuk gambar
                              child: Image.asset(
                                'assets/images/${item.car.brand}.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${item.car.brand} ${item.car.carType}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.car.showroom,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.notes ?? 'No notes here',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                            onPressed: () async {  
                                            final shouldRefresh = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetailCarPage(
                                                  carId: item.car.carId,
                                                ),
                                              ),
                                            );
                                            if (shouldRefresh == true) {
                                              setState(() {
                                                wishlist.removeWhere(
                                                  (wishlistItem) => wishlistItem.car.carId == item.car.carId
                                                );
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 7, 73, 128),
                                            minimumSize: const Size(0, 30),
                                          ),
                                          child: const Text(
                                            'Details',
                                            style: TextStyle(fontSize: 8, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 16),
                                        onPressed: () async {
                                          final updatedNote = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditNotePage(item: item),
                                            ),
                                          );
                                          if (updatedNote != null) {
                                            setState(() {
                                              item.notes = updatedNote;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 16),
                                        color: Colors.red,
                                        onPressed: () {
                                          _confirmRemoveItem(context, item.car.carId, request);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
