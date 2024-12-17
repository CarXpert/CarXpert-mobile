// car_xpert/screens/detailcar/detailcar.dart
import 'package:car_xpert/screens/detailcar/editcar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/models/carlist.dart';

class DetailCarPage extends StatefulWidget {
  final String carId;

  const DetailCarPage({required this.carId, super.key});

  @override
  State<DetailCarPage> createState() => _DetailCarPageState();
}

class _DetailCarPageState extends State<DetailCarPage> {
  late Future<Map<String, dynamic>> _carDetailWithShowroom;

  Future<Map<String, dynamic>> fetchCarDetailWithShowroom() async {
    // Fetch car detail
    final carDetailResponse = await http.get(Uri.parse('http://127.0.0.1:8000/main/json/'));

    if (carDetailResponse.statusCode == 200) {
      List<CarEntry> cars = carEntryFromJson(carDetailResponse.body);
      CarEntry car = cars.firstWhere((car) => car.pk == widget.carId);

      // Setelah mendapatkan data mobil, fetch showroom data
      final showroomResponse = await http.get(Uri.parse('http://127.0.0.1:8000/showrooms_data/'));
      if (showroomResponse.statusCode == 200) {
        final showroomData = jsonDecode(showroomResponse.body);
        List showrooms = showroomData['showrooms'];

        // Mencari showroom yang ID-nya sama dengan showroom pada mobil
        final matchingShowroom = showrooms.firstWhere(
          (s) => s['id'] == car.fields.showroom,
          orElse: () => null
        );

        // Kembalikan data mobil dan showroom dalam bentuk map
        return {
          'car': car,
          'showroom': matchingShowroom
        };
      } else {
        throw Exception('Failed to load showroom data');
      }
    } else {
      throw Exception('Failed to load car detail');
    }
  }

  @override
  void initState() {
    super.initState();
    _carDetailWithShowroom = fetchCarDetailWithShowroom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Car'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carDetailWithShowroom,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            final CarEntry car = data['car'];
            final showroom = data['showroom'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Mobil
                  Image.network(
                    'http://127.0.0.1:8000/static/images/${car.fields.brand.replaceAll(' ', '_')}.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.image_not_supported, size: 100));
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Informasi Mobil
                  _buildDetailRow('Brand', car.fields.brand),
                  _buildDetailRow('Car Type', car.fields.carType),
                  _buildDetailRow('Model', fieldsModelValues.reverse[car.fields.model]!),
                  _buildDetailRow('Color', car.fields.color),
                  _buildDetailRow('Year', car.fields.year.toString()),
                  _buildDetailRow('Fuel Type', fuelTypeValues.reverse[car.fields.fuelType]!),
                  _buildDetailRow('Cylinder Size', '${car.fields.cylinderSize} cc'),
                  _buildDetailRow('Cylinder Total', car.fields.cylinderTotal.toString()),
                  _buildDetailRow('Turbo', car.fields.turbo ? 'Yes' : 'No'),
                  _buildDetailRow('Mileage', '${car.fields.mileage} km'),
                  _buildDetailRow('STNK Expiry', _formatDate(car.fields.stnkDate)),
                  _buildDetailRow('Levy Expiry', _formatDate(car.fields.levyDate)),
                  _buildDetailRow('License Plate', car.fields.licensePlate),
                  _buildDetailRow('Price Cash', '\Rp. ${car.fields.priceCash}'),
                  _buildDetailRow('Price Credit', '\Rp. ${car.fields.priceCredit}'),
                  _buildDetailRow('Created at', _formatDate(car.fields.createdAt)),
                  _buildDetailRow('Last Update', _formatDate(car.fields.updatedAt)),

                  // Jika showroom ditemukan, tampilkan detailnya
                  if (showroom != null) ...[
                    _buildDetailRow('Showroom Name', showroom['showroom_name']),
                    _buildDetailRow('Showroom Location', showroom['showroom_location']),
                    _buildDetailRow('Showroom Regency', showroom['showroom_regency']),
                  ] else
                    const Text('Showroom not found'),

                  const SizedBox(height: 24.0),

                  // Tombol Edit
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCarPage(carId: car.pk),
                        ),
                      ).then((value) {
                        // Reload data setelah edit jika diperlukan
                        if (value == true) {
                          setState(() {
                            _carDetailWithShowroom = fetchCarDetailWithShowroom();
                          });
                        }
                      });
                    },
                    child: const Text('Edit Car'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
