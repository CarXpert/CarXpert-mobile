import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecarslist.dart' as compareListModel;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:car_xpert/screens/comparecars/view_comparison_page.dart';
import 'package:car_xpert/screens/comparecars/compare.dart';
import 'dart:convert';

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

  Future<void> fetchComparisons() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/comparecars/list-comparisons/json/?sort=$sortOrder",
      );

      if (response != null) {
        setState(() {
          comparisons = compareListModel.compareCarListFromJson(
            jsonEncode(response),
          );

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
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/comparecars/compare/$id/",
        jsonEncode({'method': 'DELETE'}),
      );

      if (response != null &&
          response['message'] == 'Comparison deleted successfully') {
        setState(() {
          comparisons.removeWhere((comparison) => comparison.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comparison deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete comparison")),
        );
      }
    } catch (e) {
      print("Error deleting comparison: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> editTitle(int id, String newTitle) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/comparecars/compare/$id/",
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
        title: Column(
          children: [
            const Text(
              "All Comparisons",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 100,
              color: Colors.amber,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: changeSortOrder,
            itemBuilder: (context) => [
              const PopupMenuItem(value: "newest", child: Text("Newest")),
              const PopupMenuItem(value: "oldest", child: Text("Oldest")),
            ],
            child: Row(
              children: [
                Text(
                  sortOrder == "newest" ? "Newest" : "Oldest",
                  style: const TextStyle(color: Colors.indigo),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comparisons.isEmpty
              ? const Center(child: Text("No comparisons available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75, 
                    ),
                    itemCount: comparisons.length,
                    itemBuilder: (context, index) {
                      final comparison = comparisons[index];
                      return _buildComparisonCard(context, comparison);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CarComparisonPage()), 
          ).then((_) => fetchComparisons());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, compareListModel.CompareCarList comparison) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(0)),
                      child: Image.asset(
                        'assets/images/${comparison.car1.brand}.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(0)),
                      child: Image.asset(
                        'assets/images/${comparison.car2.brand}.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
         
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${comparison.title}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("${comparison.car1.brand} vs ${comparison.car2.brand}"),
              ],
            ),
          ),
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.amber),
                onPressed: () => _showEditDialog(comparison.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, comparison.id),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Detail"),
                ),
              ),
            ],
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

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Comparison"),
        content: const Text("Are you sure you want to delete this comparison?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await deleteComparison(id);
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
}
