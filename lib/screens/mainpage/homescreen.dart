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
  late Future<List<CarEntry>> _carList;
  bool isAdmin = false;
  String? _selectedYearFilter;
  String? _selectedModelFilter;
  String _sortOrder = 'newest';
  String _searchQuery = ''; 

  Future<List<CarEntry>> fetchCarList() async {
    final response = await http.get(Uri.parse('https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/main/json/'));

    if (response.statusCode == 200) {
      return carEntryFromJson(response.body);
    } else {
      throw Exception('Failed to load cars');
    }
  }

  List<CarEntry> getFilteredCars(List<CarEntry> cars) {
    List<CarEntry> filteredCars = List.from(cars);

    if (_selectedModelFilter != null) {
      filteredCars = filteredCars.where((car) => 
        fieldsModelValues.reverse[car.fields.model] == _selectedModelFilter
      ).toList();
    }

    if (_selectedYearFilter != null) {
      final year = int.parse(_selectedYearFilter!);
      filteredCars = filteredCars.where((car) => 
        car.fields.year == year
      ).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredCars = filteredCars.where((car) {
        final brand = car.fields.brand.toLowerCase();
        final model = fieldsModelValues.reverse[car.fields.model]!.toLowerCase();
        return brand.contains(_searchQuery.toLowerCase()) ||
               model.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    filteredCars.sort((a, b) {
      if (_sortOrder == 'newest') {
        return b.fields.year.compareTo(a.fields.year);
      } else {
        return a.fields.year.compareTo(b.fields.year);
      }
    });

    return filteredCars;
  }

  List<String> getUniqueYears(List<CarEntry> cars) {
    return cars
        .map((car) => car.fields.year.toString())
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getUniqueModels(List<CarEntry> cars) {
    return cars
        .map((car) => fieldsModelValues.reverse[car.fields.model]!)
        .toSet()
        .toList()
        ..sort();
  }

  @override
  void initState() {
    super.initState();
    _carList = fetchCarList();
    _loadUserRole();
  }

  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('is_admin') ?? false;
    });
  }

  void _logout() async {
    final request = context.read<CookieRequest>();
    final response = await request.logout("https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/auth/logout_django/");

    if (response['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        isAdmin = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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

  void _deleteCar(String carId) async {
    final request = context.read<CookieRequest>();
    final url = 'https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/main/delete_car/$carId/';

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
            content: Text("Gagal menghapus mobil: ${response['error'] ?? 'Unknown error.'}")
          ),
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
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      // Jika pengguna belum login, arahkan ke LoginPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Jika pengguna sudah login, arahkan ke WishlistPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
      );
    }
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

  Widget buildFilterBar(List<CarEntry> cars) {
      final uniqueYears = getUniqueYears(cars);
      final uniqueModels = getUniqueModels(cars);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Year',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Select Year'),
                            value: _selectedYearFilter,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Years'),
                              ),
                              ...uniqueYears.map((year) => DropdownMenuItem<String>(
                                value: year,
                                child: Text(year),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedYearFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Model',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Select Model'),
                            value: _selectedModelFilter,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Models'),
                              ),
                              ...uniqueModels.map((model) => DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedModelFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    const Text(
                      'Sort',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _sortOrder == 'newest' ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            _sortOrder = _sortOrder == 'newest' ? 'oldest' : 'newest';
                          });
                        },
                        tooltip: _sortOrder == 'newest' ? 'Newest First' : 'Oldest First',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

  Widget buildCarGrid(List<CarEntry> cars, bool isLoggedIn) {
    final filteredCars = getFilteredCars(cars);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container dengan background image
        Container(
          padding: const EdgeInsets.all(50.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/viewmobil.png'), // Gambar background
              fit: BoxFit.cover, // Agar gambar menutupi area
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Cars',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200]!.withOpacity(0.8), // Transparansi background search bar
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search cars by brand or model...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Divider
              Container(
                height: 2,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Filter Bar
        buildFilterBar(cars),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7,
            ),
            itemCount: filteredCars.length,
            itemBuilder: (context, index) {
              final car = filteredCars[index];
              final imagePath = 'assets/images/${car.fields.brand.replaceAll(' ', '_')}.png';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.fields.brand,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Model: ${fieldsModelValues.reverse[car.fields.model]}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Year: ${car.fields.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoggedIn) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailCarPage(carId: car.pk),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Detail'),
                        ),
                      ),
                      if (isAdmin)
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Mobil'),
                                  content: const Text('Yakin ingin menghapus mobil ini?'),
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
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (!request.loggedIn) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Car Xpert"),
          leading: IconButton(
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
              return buildCarGrid(snapshot.data!, false);
            }
          },
        ),
        bottomNavigationBar: MyBottomNavBar(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
              return buildCarGrid(snapshot.data!, true);
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
