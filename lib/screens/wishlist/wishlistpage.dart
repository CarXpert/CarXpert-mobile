import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:car_xpert/models/wishlist_item.dart';
import 'package:car_xpert/screens/detailcar/detailcar.dart';
import 'package:car_xpert/screens/wishlist/editnote.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<WishlistItem> wishlist = [];
  bool isLoading = true;
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

  // Sort the list based on the current sort order
  if (sortOrder == "Newest Added") {
    listWishlist.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  } else if (sortOrder == "Oldest Added") {
    listWishlist.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
  return listWishlist;
}

  void changeSortOrder(String newOrder) {
    setState(() {
      sortOrder = newOrder;
      isLoading = true;
    });
    final request = context.read<CookieRequest>();
    fetchWishlist(request, newOrder);
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
      centerTitle: true,
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3F4F6), Color(0xFFDBE2E7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: sortOrder,
              onChanged: (String? newValue) {
                setState(() {
                  sortOrder = newValue!;
                });
              },
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              items: <String>['Newest Added', 'Oldest Added']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<WishlistItem>>(
              future: fetchWishlist(request, sortOrder), // Pass sortOrder to fetchWishlist
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

                wishlist = snapshot.data!; // Assign fetched data to wishlist
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final item = wishlist[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/${item.car.brand}.png',
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${item.car.brand} - ${item.car.carType}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.car.showroom,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.notes ?? 'No notes yet',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmRemoveItem(context, item.car.carId, request);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.green),
                                  onPressed: () async {
                                    // Navigasi ke EditNotePage dan tunggu hasilnya
                                    final updatedNote = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditNotePage(item: item),
                                      ),
                                    );

                                    // Jika ada hasil yang dikembalikan, perbarui state item
                                    if (updatedNote != null) {
                                      setState(() {
                                        item.notes = updatedNote; // Update note pada item
                                      });
                                    }
                                  },
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
                                    backgroundColor: const Color.fromARGB(255, 0, 65, 118),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: const Text('View Details'),
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
        ],
      ),
    ),
  );
}}