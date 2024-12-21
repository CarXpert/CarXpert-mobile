import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/screens/comparecars/list_compare.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:car_xpert/screens/authentication/login.dart';

class CarComparisonPage extends StatefulWidget {
  @override
  _CarComparisonPageState createState() => _CarComparisonPageState();
}

class _CarComparisonPageState extends State<CarComparisonPage> {
  late List<Car> cars = [];
  Car? selectedCar1;
  Car? selectedCar2;
  bool isComparisonVisible = false;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    String url = "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/comparecars/get-cars/";
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> carData = jsonDecode(response.body);
        setState(() {
          cars = carData.map((data) => Car.fromJson(data)).toList();
        });
      } else {
        print('Failed to fetch cars. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching cars: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching cars: $e")),
      );
    }
  }

  void compareCars() {
    if (selectedCar1 == null || selectedCar2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select two cars to compare')),
      );
      return;
    }

    setState(() {
      isComparisonVisible = true;
    });
  }

  void saveComparison() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (selectedCar1 == null || selectedCar2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select two cars to save comparison')),
      );
      return;
    }

    final bodyData = {
      'car_one_id': selectedCar1!.id,
      'car_two_id': selectedCar2!.id,
    };

    print("Request Body: $bodyData");

    try {
      final response = await request.post(
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/comparecars/compare/",
        bodyData,
      );

      if (response['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comparison saved successfully')),
        );
      } else {
        final error = response['error'] ?? 'Failed to save comparison';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save comparison: $error')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save comparison: $e')),
      );
    }
  }

  void viewAllComparisons() {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAllComparisonPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Cars'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: cars.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Compare Cars",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 3,
                      width: 100,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: "Choose Car 1",
                            value: selectedCar1,
                            onChanged: (Car? car) {
                              setState(() {
                                selectedCar1 = car;
                                isComparisonVisible = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            label: "Choose Car 2",
                            value: selectedCar2,
                            onChanged: (Car? car) {
                              setState(() {
                                selectedCar2 = car;
                                isComparisonVisible = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCarImage(selectedCar1, "Car 1"),
                        const SizedBox(width: 16),
                        _buildCarImage(selectedCar2, "Car 2"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isComparisonVisible)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.indigo,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                Text("Spesifikasi",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text("Mobil 1",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text("Mobil 2",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Table(
                            border: TableBorder.all(color: Colors.grey),
                            children: [
                              _buildTableRow("Brand", selectedCar1?.brand,
                                  selectedCar2?.brand),
                              _buildTableRow("Model", selectedCar1?.model,
                                  selectedCar2?.model),
                              _buildTableRow("Tahun", "${selectedCar1?.year}",
                                  "${selectedCar2?.year}"),
                              _buildTableRow(
                                  "Jenis Bahan Bakar",
                                  selectedCar1?.fuelType.name,
                                  selectedCar2?.fuelType.name),
                              _buildTableRow("Warna", selectedCar1?.color,
                                  selectedCar2?.color),
                              _buildTableRow(
                                "Harga",
                                "${selectedCar1?.priceCash} IDR",
                                "${selectedCar2?.priceCash} IDR",
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: compareCars,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Compare Cars"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: viewAllComparisons,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("View All"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: saveComparison,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Save Comparison"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required Car? value,
    required Function(Car?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        DropdownButton<Car>(
          value: value,
          onChanged: onChanged,
          items: cars.map((Car car) {
            return DropdownMenuItem<Car>(
              value: car,
              child: Text('${car.brand} - ${car.model}'),
            );
          }).toList(),
          isExpanded: true,
          hint: Text(label),
        ),
      ],
    );
  }

  Widget _buildCarImage(Car? car, String placeholder) {
    return Expanded(
      child: Column(
        children: [
          car != null
              ? Image.asset(
                  'assets/images/${car.brand}.png',
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported,
                        size: 80, color: Colors.grey);
                  },
                )
              : Image.asset(
                'assets/images/logobulat.png', // Gambar placeholder
                height: 150,
                fit: BoxFit.cover,
              ),
          Text(
            car != null ? '${car.brand} ${car.model}' : placeholder,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String spec, String? car1Value, String? car2Value) {
    return TableRow(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(spec,
                style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(car1Value ?? "-")),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(car2Value ?? "-")),
      ],
    );
  }
}
