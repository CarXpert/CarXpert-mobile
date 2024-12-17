import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/screens/comparecars/list_compare.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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

    String url = "http://127.0.0.1:8000/comparecars/get-cars/";
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10), // Tambahkan timeout
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
      final request = context.read<CookieRequest>();

      final response = await request.post(
        "http://127.0.0.1:8000/comparecars/compare/",
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
        title: Text('Compare Cars'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: cars.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Compare Cars",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(thickness: 2),
                    SizedBox(height: 16),
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
                        SizedBox(width: 16),
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
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCarImage(selectedCar1, "Car 1"),
                        const SizedBox(width: 16),
                        _buildCarImage(selectedCar2, "Car 2"),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (isComparisonVisible)
                      Table(
                        border: TableBorder.all(color: Colors.grey),
                        children: [
                          _buildTableRow("Brand", selectedCar1?.brand, selectedCar2?.brand),
                          _buildTableRow("Model", selectedCar1?.model, selectedCar2?.model),
                          _buildTableRow("Year", "${selectedCar1?.year}", "${selectedCar2?.year}"),
                          _buildTableRow("Fuel Type", selectedCar1?.fuelType.name, selectedCar2?.fuelType.name),
                          _buildTableRow("Color", selectedCar1?.color, selectedCar2?.color),
                          _buildTableRow("Price", "${selectedCar1?.priceCash} IDR", "${selectedCar2?.priceCash} IDR"),
                        ],
                      ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: compareCars,
                          child: Text("Compare Cars"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                        ElevatedButton(
                          onPressed: viewAllComparisons,
                          child: Text("View All Comparison"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                        ElevatedButton(
                          onPressed: saveComparison,
                          child: Text("Save Comparison"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
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
        Text(label, style: TextStyle(fontSize: 16)),
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
    if (car != null) {
      final imagePath = 'assets/images/${car.brand}.png';
      print('Loading Image: $imagePath'); // Debug path gambar
    }

    return Expanded(
      child: Column(
        children: [
          car != null
              ? Image.asset(
                  'assets/images/${car.brand}.png',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    print('Image not found: assets/images/${car.brand}.png');
                    return const Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
                  },
                )
              : const Placeholder(fallbackHeight: 150, fallbackWidth: 150),
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
        Padding(padding: const EdgeInsets.all(8.0), child: Text(spec, style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(car1Value ?? "-")),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(car2Value ?? "-")),
      ],
    );
  }
}
