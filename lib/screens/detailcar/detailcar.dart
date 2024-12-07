// car_xpert/screens/detailcar/detailcar.dart
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
  late Future<CarEntry> _carDetail;

  // Fungsi untuk mengambil detail mobil berdasarkan carId
  Future<CarEntry> fetchCarDetail() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/main/json/'));

    if (response.statusCode == 200) {
      List<CarEntry> cars = carEntryFromJson(response.body);
      return cars.firstWhere((car) => car.pk == widget.carId);
    } else {
      throw Exception('Failed to load car detail');
    }
  }

  @override
  void initState() {
    super.initState();
    _carDetail = fetchCarDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Car'),
      ),
      body: FutureBuilder<CarEntry>(
        future: _carDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          } else {
            final car = snapshot.data!;
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
                  _buildDetailRow('Showroom', car.fields.showroom),
                  const SizedBox(height: 24.0),
                  // Tombol Edit (Opsional)
                  ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman edit jika diperlukan
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => EditCarPage(carId: car.pk)));
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

  // Widget untuk menampilkan baris detail
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

  // Fungsi untuk memformat tanggal
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
