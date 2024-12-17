import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/models/comparecars.dart'; // Model comparecars.dart

class ViewComparisonPage extends StatefulWidget {
  final String car1Brand;
  final String car1Model;
  final String car2Brand;
  final String car2Model;

  const ViewComparisonPage({
    required this.car1Brand,
    required this.car1Model,
    required this.car2Brand,
    required this.car2Model,
    Key? key,
  }) : super(key: key);

  @override
  _ViewComparisonPageState createState() => _ViewComparisonPageState();
}

class _ViewComparisonPageState extends State<ViewComparisonPage> {
  List<Car> _allCars = [];
  Car? car1;
  Car? car2;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  // Ambil semua data mobil dari backend
  Future<void> fetchCars() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/comparecars/get-cars/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Konversi data menjadi list mobil
        setState(() {
          _allCars = data.map((json) => Car.fromJson(json)).toList();

          // Cari mobil berdasarkan brand dan model
          car1 = _findCar(widget.car1Brand, widget.car1Model);
          car2 = _findCar(widget.car2Brand, widget.car2Model);

          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch cars');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Cari mobil berdasarkan brand dan model
  Car _findCar(String brand, String model) {
  return _allCars.firstWhere(
    (car) => car.brand == brand && car.model == model,
    orElse: () => Car(
      id: '',
      brand: brand,
      model: model,
      year: 2020, // Default year
      fuelType: FuelType.GASOLINE, // Default fuel type
      color: 'Unknown', // Default color
      priceCash: 0, // Default price
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.car1Brand} vs ${widget.car2Brand}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (car1 == null || car2 == null)
              ? const Center(
                  child: Text(
                    "Comparison data is not available",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header dengan gambar dan detail mobil
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildCarDetails(car1!)),
                          const SizedBox(width: 16.0),
                          Expanded(child: _buildCarDetails(car2!)),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Tabel perbandingan
                      _buildComparisonTable(car1!, car2!),
                    ],
                  ),
                ),
    );
  }

  // Widget untuk menampilkan detail mobil
  Widget _buildCarDetails(Car car) {
    return Column(
      children: [
        Text(
          "${car.brand} ${car.model}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Image.network(
          'https://your-static-url.com/images/${car.brand}.png',
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported,
                size: 80, color: Colors.grey);
          },
        ),
      ],
    );
  }

  // Widget untuk membangun tabel perbandingan
  Widget _buildComparisonTable(Car car1, Car car2) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        _buildTableRow("Brand", car1.brand, car2.brand),
        _buildTableRow("Model", car1.model, car2.model),
        _buildTableRow("Year", "${car1.year}", "${car2.year}"),
        _buildTableRow("Fuel Type", car1.fuelType.name, car2.fuelType.name),
        _buildTableRow("Color", car1.color, car2.color),
        _buildTableRow("Price", "${car1.priceCash} IDR", "${car2.priceCash} IDR"),
      ],
    );
  }

  TableRow _buildTableRow(String spec, String car1Value, String car2Value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(spec, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(car1Value),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(car2Value),
        ),
      ],
    );
  }
}