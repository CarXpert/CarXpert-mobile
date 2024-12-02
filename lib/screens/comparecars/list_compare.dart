import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecars.dart'; // Impor model CompareCar

class ListCompareScreen extends StatefulWidget {
  const ListCompareScreen({super.key});

  @override
  _ListCompareScreenState createState() => _ListCompareScreenState();
}

class _ListCompareScreenState extends State<ListCompareScreen> {
  List<CompareCar> comparisonList = [];  // List untuk menyimpan data perbandingan mobil
  String sortOrder = 'newest';  // Pengurutan berdasarkan newest atau oldest

  @override
  void initState() {
    super.initState();
    _fetchComparisonList();
  }

  // Fungsi untuk memuat daftar perbandingan mobil
  Future<void> _fetchComparisonList() async {
    // Simulasi pemuatan data dari server
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      comparisonList = [
        CompareCar(
          model: "Car Comparison Model 1",
          pk: 1,
          fields: Fields(comparecar: 1, user: 1),
        ),
        CompareCar(
          model: "Car Comparison Model 2",
          pk: 2,
          fields: Fields(comparecar: 2, user: 1),
        ),
      ];
    });
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus perbandingan
  void _deleteComparison(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comparison'),
          content: const Text('Are you sure you want to delete this comparison?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  comparisonList.removeWhere((item) => item.pk == id);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengurutkan daftar berdasarkan urutan yang dipilih
  void _sortComparisons() {
    setState(() {
      if (sortOrder == 'newest') {
        comparisonList.sort((a, b) => b.pk.compareTo(a.pk)); // Urutkan berdasarkan pk, descending
      } else {
        comparisonList.sort((a, b) => a.pk.compareTo(b.pk)); // Urutkan berdasarkan pk, ascending
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigasi ke halaman penambahan perbandingan baru
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown untuk memilih urutan
            Row(
              children: [
                const Text('Sort By: '),
                DropdownButton<String>(
                  value: sortOrder,
                  onChanged: (String? newValue) {
                    setState(() {
                      sortOrder = newValue!;
                      _sortComparisons();
                    });
                  },
                  items: <String>['newest', 'oldest']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Daftar perbandingan mobil
            Expanded(
              child: comparisonList.isNotEmpty
                  ? ListView.builder(
                      itemCount: comparisonList.length,
                      itemBuilder: (context, index) {
                        final compareCar = comparisonList[index];

                        return Dismissible(
                          key: Key(compareCar.pk.toString()),
                          onDismissed: (direction) {
                            _deleteComparison(compareCar.pk);
                          },
                          background: Container(color: Colors.red),
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(compareCar.model),
                              subtitle: Text(
                                  'Compare car ID: ${compareCar.pk}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteComparison(compareCar.pk);
                                },
                              ),
                              onTap: () {
                                // Tindakan saat item perbandingan ditekan
                              },
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('No saved comparisons yet.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
