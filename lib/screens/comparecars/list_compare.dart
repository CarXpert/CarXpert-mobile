import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecarslist.dart' as compareListModel;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:car_xpert/screens/authentication/login.dart';
import 'package:car_xpert/screens/comparecars/view_comparison_page.dart';

class ViewAllComparisonPage extends StatefulWidget {
  @override
  _ViewAllComparisonPageState createState() => _ViewAllComparisonPageState();
}

class _ViewAllComparisonPageState extends State<ViewAllComparisonPage> {
  List<compareListModel.CompareCarList> comparisons = [];
  bool isLoading = true;
  String sortOrder = "newest";

  @override
  void initState() {
    super.initState();
    fetchComparisons();
  }

  // Fetch comparisons dari API Django
  Future<void> fetchComparisons() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "http://127.0.0.1:8000/comparecars/list-comparisons/json/?sort=$sortOrder",
      );

      if (response != null) {
        setState(() {
          comparisons = compareListModel.compareCarListFromJson(
            jsonEncode(response),
          );

          // Sorting ulang di frontend jika diperlukan
          if (sortOrder == "newest") {
            comparisons.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
          } else if (sortOrder == "oldest") {
            comparisons.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }


  Future<void> deleteComparison(int id) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        "http://127.0.0.1:8000/comparecars/compare/$id/",
        jsonEncode({'method': 'DELETE'}),
      );

      if (response != null && response['message'] == 'Comparison deleted successfully') {
        // Hapus item dari daftar comparisons
        setState(() {
          comparisons.removeWhere((comparison) => comparison.id == id);
        });
        print("Comparison deleted successfully.");
      } else {
        print("Failed to delete comparison. Response: $response");
      }
    } catch (e) {
      print("Error deleting comparison: $e");
    }
  }




  Future<void> editTitle(int id, String newTitle) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        "http://127.0.0.1:8000/comparecars/compare/$id/",
        jsonEncode({'method': 'PUT', 'title': newTitle}),
      );

      if (response != null) {
        setState(() {
          comparisons.firstWhere((comparison) => comparison.id == id).title =
              newTitle;
        });
      }
    } catch (e) {
      print("Error editing title: $e");
    }
  }

  void changeSortOrder(String newOrder) {
    setState(() {
      sortOrder = newOrder;
      isLoading = true;
    });
    fetchComparisons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("All Comparisons"),
            const SizedBox(width: 16), // Jarak antara judul dan dropdown
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  sortOrder = value;
                  isLoading = true; // Set ke loading state
                });
                fetchComparisons(); // Ambil ulang data dengan urutan yang baru
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: "newest", child: Text("Newest")),
                const PopupMenuItem(value: "oldest", child: Text("Oldest")),
              ],
              child: Row(
                children: [
                  Text(
                    sortOrder == "newest" ? "Newest" : "Oldest",
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true, // Pusatkan judul dan tombol
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comparisons.isEmpty
              ? const Center(child: Text("No comparisons available"))
              : ListView.builder(
                  itemCount: comparisons.length,
                  itemBuilder: (context, index) {
                    final comparison = comparisons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                comparison.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(comparison.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDelete(context, comparison.id),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "${comparison.car1.brand} vs ${comparison.car2.brand}",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewComparisonPage(
                                car1Brand: comparison.car1.brand,
                                car1Model: comparison.car1.model,
                                car2Brand: comparison.car2.brand,
                                car2Model: comparison.car2.model,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }


  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Comparison"),
        content: const Text("Are you sure you want to delete this comparison?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Tutup dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Tutup dialog
              await deleteComparison(id); // Hapus dan perbarui UI
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }



  void _showEditDialog(int id) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Title"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(labelText: "New Title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                editTitle(id, _controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
