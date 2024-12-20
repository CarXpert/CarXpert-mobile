import 'package:car_xpert/screens/authentication/login.dart';
import 'package:car_xpert/screens/detailcar/editcar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/models/carlist.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import paket intl

class DetailCarPage extends StatefulWidget {
  final String carId;

  const DetailCarPage({required this.carId, super.key});

  @override
  State<DetailCarPage> createState() => _DetailCarPageState();
}

class _DetailCarPageState extends State<DetailCarPage> {
  late Future<Map<String, dynamic>> _carDetailWithShowroom;
  bool isAdmin = false;
  bool isInWishlist = false;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _carDetailWithShowroom = fetchCarDetailWithShowroom();
    _loadUserRole();
    _checkIfInWishlist();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('is_admin') ?? false;
    });
  }

  Future<Map<String, dynamic>> fetchCarDetailWithShowroom() async {
    // Fetch car detail
    final carDetailResponse =
        await http.get(Uri.parse('http://127.0.0.1:8000/main/json/'));

    if (carDetailResponse.statusCode == 200) {
      List<CarEntry> cars = carEntryFromJson(carDetailResponse.body);
      CarEntry car = cars.firstWhere((car) => car.pk == widget.carId);

      final showroomResponse =
          await http.get(Uri.parse('http://127.0.0.1:8000/showrooms_data/'));
      if (showroomResponse.statusCode == 200) {
        final showroomData = jsonDecode(showroomResponse.body);
        List showrooms = showroomData['showrooms'];

        final matchingShowroom = showrooms.firstWhere(
          (s) => s['id'] == car.fields.showroom,
          orElse: () => null,
        );

        return {
          'car': car,
          'showroom': matchingShowroom,
        };
      } else {
        throw Exception('Failed to load showroom data');
      }
    } else {
      throw Exception('Failed to load car detail');
    }
  }

  Future<void> _checkIfInWishlist() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'http://127.0.0.1:8000/wishlist/check/',
        {'car_id': widget.carId},
      );

      if (response['status'] == 'success') {
        setState(() {
          isInWishlist = response['in_wishlist'];
        });
      }
    } catch (e) {
      print("Error checking wishlist: $e");
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      final request = context.read<CookieRequest>();
      if (!request.loggedIn) {
      // Jika pengguna belum login, arahkan ke LoginPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      }
      final response = await request.post(
        'http://127.0.0.1:8000/wishlist/toggle/',
        {'car_id': widget.carId},
      );

      if (response['status'] == 'success') {
        setState(() {
          isInWishlist = response['in_wishlist'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );

        // Jika item dihapus dari wishlist (unlove), pop dengan nilai true
        if (!isInWishlist) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update wishlist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.3;
    final imageWidth = size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Car'),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey, // Ubah warna di sini
            ),
            onPressed: _toggleWishlist,
            tooltip: isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
          ),
        ],
        backgroundColor: Colors.white, // Ubah warna AppBar jika perlu
        iconTheme: IconThemeData(
          color: Colors.black, // Ubah warna ikon AppBar lainnya
        ),
        titleTextStyle: TextStyle(
          color: Colors.black, // Ubah warna teks judul
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carDetailWithShowroom,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            final CarEntry car = data['car'];
            final showroom = data['showroom'];

            final imagePath =
                'assets/images/${car.fields.brand.replaceAll(' ', '_')}.png';

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Gambar Mobil
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      height: imageHeight,
                      width: imageWidth,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          color: Colors.grey[200],
                          child: const Center(
                              child:
                                  Icon(Icons.image_not_supported, size: 100)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Detail Mobil
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Brand', car.fields.brand),
                        _buildDetailRow('Car Type', car.fields.carType),
                        _buildDetailRow('Model',
                            fieldsModelValues.reverse[car.fields.model]!),
                        _buildDetailRow('Color', car.fields.color),
                        _buildDetailRow('Year', car.fields.year.toString()),
                        _buildDetailRow('Fuel Type',
                            fuelTypeValues.reverse[car.fields.fuelType]!),
                        _buildDetailRow('Cylinder Size',
                            _formatNumber(car.fields.cylinderSize) + ' cc'),
                        _buildDetailRow('Cylinder Total',
                            _formatNumber(car.fields.cylinderTotal)),
                        _buildDetailRow(
                            'Turbo', car.fields.turbo ? 'Yes' : 'No'),
                        _buildDetailRow('Mileage',
                            _formatNumber(car.fields.mileage) + ' km'),
                        _buildDetailRow('STNK Expiry',
                            _formatDate(car.fields.stnkDate)),
                        _buildDetailRow(
                            'Levy Expiry', _formatDate(car.fields.levyDate)),
                        _buildDetailRow(
                            'License Plate', car.fields.licensePlate),
                        _buildDetailRow('Price Cash',
                            currencyFormat.format(car.fields.priceCash)),
                        _buildDetailRow('Price Credit',
                            currencyFormat.format(car.fields.priceCredit)),
                        _buildDetailRow(
                            'Created at', _formatDate(car.fields.createdAt)),
                        _buildDetailRow(
                            'Last Update', _formatDate(car.fields.updatedAt)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Detail Showroom
                showroom != null
                    ? Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Showroom Details',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              _buildDetailRow(
                                  'Showroom Name', showroom['showroom_name']),
                              _buildDetailRow('Location',
                                  showroom['showroom_location']),
                              _buildDetailRow(
                                  'Regency', showroom['showroom_regency']),
                            ],
                          ),
                        ),
                      )
                    : const Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Showroom not found',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                const SizedBox(height: 24.0),

                // Tombol Edit untuk Admin
                if (isAdmin)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCarPage(carId: car.pk),
                        ),
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            _carDetailWithShowroom =
                                fetchCarDetailWithShowroom();
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Car'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 130, // Lebar label diperluas untuk tampilan yang lebih baik
            child: Text(
              '$label:',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          // Value
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatNumber(int number) {
    return NumberFormat.decimalPattern('id_ID').format(number);
  }
}
