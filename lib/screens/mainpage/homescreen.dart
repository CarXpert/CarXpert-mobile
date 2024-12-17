// car_xpert/screens/mainpage/homescreen.dart
import 'package:car_xpert/screens/bookshowroom/bookshowroom.dart';
import 'package:car_xpert/screens/news/newsarticles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk JSON parsing
import 'package:car_xpert/models/carlist.dart'; // Import model CarEntry
import 'package:car_xpert/widgets/navbar.dart';
import 'package:car_xpert/screens/wishlist/wishlistpage.dart';
import 'package:car_xpert/screens/comparecars/compare.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Import CookieRequest
import 'package:car_xpert/screens/authentication/login.dart'; // Import LoginPage
import 'package:car_xpert/screens/detailcar/detailcar.dart'; // Import DetailCarPage
import 'package:car_xpert/screens/mainpage/addcar.dart'; // Import AddCarPage

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
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/main/json/'));

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
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookShowroomScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarComparisonPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewsArticleListPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Fungsi untuk logout
  void _logout() async {
    final request = context.read<CookieRequest>();
    final response = await request.logout(
        "http://127.0.0.1:8000/auth/logout_django/"); // Pastikan endpoint logout sesuai di Django

    if (response['status'] == 'success') {
      // Navigasi ke LoginPage dan hapus semua route sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout berhasil.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout gagal.")),
      );
    }
  }

  // Fungsi untuk menghapus mobil
  // Future<void> _deleteCar(String carId) async {
  //   final request = context.read<CookieRequest>();
  //   final deleteUrl = 'http:main/delete_car/$carId/';

  //   final response = await request.delete(deleteUrl, {});

  //   if (response['status'] == 'success') {
  //     // Jika berhasil, refresh daftar mobil
  //     setState(() {
  //       _carList = fetchCarList();
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Mobil berhasil dihapus.")),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Gagal menghapus mobil: ${response['message']}")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Xpert"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Tampilkan konfirmasi sebelum logout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      child: const Text('Batal'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CarEntry>>(
        future: _carList, // Menggunakan data yang sudah di-fetch
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Menunggu data
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
                final imageUrl =
                    'http://127.0.0.1:8000/static/images/${car.fields.brand.replaceAll(' ', '_')}.png';

                return Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar mobil berdasarkan brand
                      Image.network(
                        imageUrl, // Menggunakan URL gambar dari Django static folder
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Icon(Icons.image_not_supported,
                                  size:
                                      50)); // Placeholder jika gambar tidak ditemukan
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(car.fields.brand,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                                'Model: ${fieldsModelValues.reverse[car.fields.model]}',
                                style: const TextStyle(fontSize: 12)),
                            Text('Color: ${car.fields.color}',
                                style: const TextStyle(fontSize: 12)),
                            Text('Year: ${car.fields.year}',
                                style: const TextStyle(fontSize: 12)),
                            Text('Mileage: ${car.fields.mileage} km',
                                style: const TextStyle(fontSize: 12)),
                            Text('Price: \Rp. ${car.fields.priceCash}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigasi ke DetailCarPage dengan mengirimkan car ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailCarPage(carId: car.pk),
                                      ),
                                    );
                                  },
                                  child: const Text('Detail'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    // Tampilkan konfirmasi sebelum menghapus
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Hapus Mobil'),
                                        content: const Text(
                                            'Apakah Anda yakin ingin menghapus mobil ini?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Batal'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Hapus',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              // _deleteCar(car.pk);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
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
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke AddCarPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarPage()),
          ).then((value) {
            // Setelah kembali dari AddCarPage, refresh daftar mobil
            setState(() {
              _carList = fetchCarList();
            });
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Car',
      ),
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
