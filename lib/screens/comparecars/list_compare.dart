import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecarslist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:car_xpert/screens/authentication/login.dart';

class ViewAllComparisonPage extends StatefulWidget {
  @override
  _ViewAllComparisonPageState createState() => _ViewAllComparisonPageState();
}

class _ViewAllComparisonPageState extends State<ViewAllComparisonPage> {
  List<CompareCarList> comparisons = [];
  String sortOrder = "newest"; // Variabel untuk menyimpan urutan pengurutan
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    if (request.loggedIn) {
      fetchComparisons();
    } else {
      // Arahkan pengguna ke halaman login jika belum login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }


  Future<void> fetchComparisons() async {
  try {
    // Ambil instance CookieRequest
    final request = context.read<CookieRequest>();

    // Kirim permintaan dengan cookie sesi
    final response = await request.get(
      "http://127.0.0.1:8000/comparecars/list-comparisons/json/",
    );

    if (response != null) {
      setState(() {
        // Akses langsung data response tanpa `.body`
        comparisons = compareCarListFromJson(jsonEncode(response));
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load comparisons.");
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error: $e");
  }
}




  void changeSortOrder(String newSortOrder) {
    setState(() {
      sortOrder = newSortOrder;
      isLoading = true;
    });
    fetchComparisons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Comparisons"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => changeSortOrder(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "newest",
                child: Text("Newest"),
              ),
              PopupMenuItem(
                value: "oldest",
                child: Text("Oldest"),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : comparisons.isEmpty
              ? Center(child: Text("No comparisons available"))
              : ListView.builder(
                  padding: EdgeInsets.all(12.0),
                  itemCount: comparisons.length,
                  itemBuilder: (context, index) {
                    final comparison = comparisons[index];
                    return ComparisonCard(
                      comparison: comparison,
                      onDelete: () => deleteComparison(comparison.id),
                    );
                  },
                ),
    );
  }

  Future<void> deleteComparison(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/comparecars/delete-comparison/$id/'),
      );
      if (response.statusCode == 200) {
        setState(() {
          comparisons.removeWhere((comparison) => comparison.id == id);
        });
      } else {
        print("Error: Failed to delete comparison. Status code: ${response.statusCode}");
        throw Exception('Failed to delete comparison');
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}

class ComparisonCard extends StatelessWidget {
  final CompareCarList comparison;
  final VoidCallback onDelete;

  const ComparisonCard({
    required this.comparison,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comparison.title ?? 'No Title',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Image.network(
                    'https://your-static-url.com/images/${comparison.car1.brand}.png',
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Image.network(
                    'https://your-static-url.com/images/${comparison.car2.brand}.png',
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              '${comparison.car1.brand} (${comparison.car1.model}) vs ${comparison.car2.brand} (${comparison.car2.model})',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date Added: ${comparison.dateAdded.toLocal()}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
