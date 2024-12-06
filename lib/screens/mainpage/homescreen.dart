// car_xpert/screens/mainpage/homescreen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk JSON parsing
import 'package:car_xpert/models/carlist.dart'; // Import model CarEntry
import 'package:car_xpert/widgets/navbar.dart';
import 'package:car_xpert/screens/wishlist/wishlistpage.dart';  
import 'package:car_xpert/screens/comparecars/compare.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Future<List<CarEntry>> _carList; // Menampung data car entries

  // Fungsi untuk mengambil data dari API Django
  Future<List<CarEntry>> fetchCarList() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/main/json/'));

    if (response.statusCode == 200) {
      return carEntryFromJson(response.body); // Parse JSON ke List<CarEntry>
    } else {
      throw Exception('Failed to load cars');
    }
  }

  @override
  void initState() {
    super.initState();
    _carList = fetchCarList(); // Memanggil fungsi fetch saat state dimuat
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarComparisonPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Xpert"),
      ),
      body: FutureBuilder<List<CarEntry>>(
        future: _carList, // Menggunakan data yang sudah di-fetch
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Menunggu data
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cars available.'));
          } else {
            // Jika data tersedia
            final cars = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                // URL gambar berdasarkan brand mobil
                final imageUrl = 'http://127.0.0.1:8000/static/images/${car.fields.brand.replaceAll(' ', '_')}.png';
                
                return Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar mobil berdasarkan brand
                      Image.network(
                        imageUrl, // Menggunakan URL gambar dari Django static folder
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.image_not_supported, size: 50)); // Placeholder jika gambar tidak ditemukan
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(car.fields.brand, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Model: ${fieldsModelValues.reverse[car.fields.model]}', style: TextStyle(fontSize: 12)),
                            Text('Color: ${car.fields.color}', style: TextStyle(fontSize: 12)),
                            Text('Year: ${car.fields.year}', style: TextStyle(fontSize: 12)),
                            Text('Mileage: ${car.fields.mileage} km', style: TextStyle(fontSize: 12)),
                            Text('Price: \$${car.fields.priceCash}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            // Tombol detail
                            ElevatedButton(
                              onPressed: () {
                                // Arahkan ke halaman detail, sesuaikan URL
                                Navigator.pushNamed(context, '/car/${car.pk}');
                              },
                              child: const Text('Detail'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
