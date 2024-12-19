import 'package:car_xpert/screens/bookshowroom/bookshowroom.dart';
import 'package:car_xpert/screens/news/newsarticles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/models/carlist.dart';
import 'package:car_xpert/widgets/navbar.dart';
import 'package:car_xpert/screens/wishlist/wishlistpage.dart';
import 'package:car_xpert/screens/comparecars/compare.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:car_xpert/screens/authentication/login.dart';
import 'package:car_xpert/screens/detailcar/detailcar.dart';
import 'package:car_xpert/screens/mainpage/addcar.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Future<List<CarEntry>> _carList; // Daftar mobil
  bool isAdmin = false; // Peran pengguna

  // Fungsi untuk mengambil daftar mobil dari API Django
  Future<List<CarEntry>> fetchCarList() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/main/json/'));

    if (response.statusCode == 200) {
      return carEntryFromJson(response.body);
    } else {
      throw Exception('Failed to load cars');
    }
  }

  @override
  void initState() {
    super.initState();
    _carList = fetchCarList(); // Ambil daftar mobil
    _loadUserRole(); // Ambil peran pengguna
  }

  // Ambil peran pengguna dari SharedPreferences
  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('is_admin') ?? false;
    });
  }

  // Fungsi logout
  void _logout() async {
    final request = context.read<CookieRequest>();
    final response =
        await request.logout("http://127.0.0.1:8000/auth/logout_django/");

    if (response['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus data pengguna
      setState(() {
        isAdmin = false; // Reset peran
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Halaman belum login
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
  void _deleteCar(String carId) async {
    final request = context.read<CookieRequest>();
    final url = 'http://127.0.0.1:8000/main/delete_car/$carId/';

    try {
      final response = await request.post(
        url,
        jsonEncode({'method': 'DELETE'}),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mobil berhasil dihapus.")),
        );
        setState(() {
          _carList = fetchCarList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal menghapus mobil: ${response['error'] ?? 'Unknown error.'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Halaman untuk pengguna yang belum login
    if (!request.loggedIn) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hilangkan tombol back
          title: const Text("Car Xpert"),
          leading: IconButton( // Pindahkan tombol login ke kiri atas
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ),
        body: FutureBuilder<List<CarEntry>>(
          future: _carList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No cars available.'));
            } else {
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
                  final imagePath =
                      'assets/images/${car.fields.brand.replaceAll(' ', '_')}.png';

                  return Card(
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported, size: 50),
                              );
                            },
                          ),
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
                                  'Model: ${fieldsModelValues.reverse[car.fields.model]}'),
                              Text('Year: ${car.fields.year}'),
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

    // Halaman utama untuk pengguna yang sudah login
    return WillPopScope(
      onWillPop: () async => false, // **Cegah tombol back**
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hilangkan tombol back
          title: const Text("Car Xpert"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
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
          future: _carList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No cars available.'));
            } else {
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
                  final imagePath =
                      'assets/images/${car.fields.brand.replaceAll(' ', '_')}.png';

                  return Card(
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported, size: 50),
                              );
                            },
                          ),
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
                                  'Model: ${fieldsModelValues.reverse[car.fields.model]}'),
                              Text('Year: ${car.fields.year}'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailCarPage(carId: car.pk),
                              ),
                            );
                          },
                          child: const Text('Detail'),
                        ),
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Mobil'),
                                  content: const Text(
                                      'Yakin ingin menghapus mobil ini?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Batal'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteCar(car.pk);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddCarPage()),
                  ).then((value) {
                    setState(() {
                      _carList = fetchCarList();
                    });
                  });
                },
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: MyBottomNavBar(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
