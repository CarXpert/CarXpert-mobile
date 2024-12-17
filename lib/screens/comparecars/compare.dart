import 'package:flutter/material.dart';
import 'package:car_xpert/models/comparecars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/screens/comparecars/list_compare.dart'; // Import list_compare.dart
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
    String url = "http://localhost:8000/comparecars/get-cars/";
    final response =
        await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> carData = jsonDecode(response.body);
      setState(() {
        cars = carData.map((data) => Car.fromJson(data)).toList();
      });
    } else {
      print('Failed to fetch cars');
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
      // Pastikan `request` berasal dari `context.watch<CookieRequest>()`
      final request = context.read<CookieRequest>();

      // Perbaiki pemanggilan `post` dengan dua argumen
      final response = await request.post(
        "http://127.0.0.1:8000/comparecars/compare/", // URL tujuan
        bodyData, // Data dalam bentuk Map<String, dynamic>
      );

      // Tangani respons
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
        builder: (context) => ViewAllComparisonPage(), // Navigasi ke list_compare.dart
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
                    // Title
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

                    // Dropdowns for Car Selection
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Choose Car 1",
                                  style: TextStyle(fontSize: 16)),
                              DropdownButton<Car>(
                                value: selectedCar1,
                                onChanged: (Car? car) {
                                  setState(() {
                                    selectedCar1 = car;
                                    isComparisonVisible = false;
                                  });
                                },
                                items: cars.map((Car car) {
                                  return DropdownMenuItem<Car>(
                                    value: car,
                                    child: Text('${car.brand} - ${car.model}'),
                                  );
                                }).toList(),
                                isExpanded: true,
                                hint: Text("Car 1"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Choose Car 2",
                                  style: TextStyle(fontSize: 16)),
                              DropdownButton<Car>(
                                value: selectedCar2,
                                onChanged: (Car? car) {
                                  setState(() {
                                    selectedCar2 = car;
                                    isComparisonVisible = false;
                                  });
                                },
                                items: cars.map((Car car) {
                                  return DropdownMenuItem<Car>(
                                    value: car,
                                    child: Text('${car.brand} - ${car.model}'),
                                  );
                                }).toList(),
                                isExpanded: true,
                                hint: Text("Car 2"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Images of Cars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              selectedCar1 != null
                                  ? Image.network(
                                      'https://via.placeholder.com/150',
                                      height: 150,
                                    )
                                  : Placeholder(
                                      fallbackHeight: 150,
                                      fallbackWidth: 150,
                                    ),
                              Text(
                                selectedCar1 != null
                                    ? '${selectedCar1!.brand} ${selectedCar1!.model}'
                                    : "Car 1",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              selectedCar2 != null
                                  ? Image.network(
                                      'https://via.placeholder.com/150',
                                      height: 150,
                                    )
                                  : Placeholder(
                                      fallbackHeight: 150,
                                      fallbackWidth: 150,
                                    ),
                              Text(
                                selectedCar2 != null
                                    ? '${selectedCar2!.brand} ${selectedCar2!.model}'
                                    : "Car 2",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Comparison Table
                    if (isComparisonVisible)
                      Table(
                        border: TableBorder.all(color: Colors.grey),
                        children: [
                          _buildTableRow("Brand", selectedCar1?.brand,
                              selectedCar2?.brand),
                          _buildTableRow("Model", selectedCar1?.model,
                              selectedCar2?.model),
                          _buildTableRow("Year", "${selectedCar1?.year}",
                              "${selectedCar2?.year}"),
                          _buildTableRow("Fuel Type",
                              selectedCar1?.fuelType.name,
                              selectedCar2?.fuelType.name),
                          _buildTableRow("Color", selectedCar1?.color,
                              selectedCar2?.color),
                          _buildTableRow(
                            "Price",
                            selectedCar1 != null
                                ? "${selectedCar1!.priceCash} IDR"
                                : "-",
                            selectedCar2 != null
                                ? "${selectedCar2!.priceCash} IDR"
                                : "-",
                          ),
                        ],
                      ),
                    SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: compareCars,
                          child: Text("Compare Cars"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                        ElevatedButton(
                          onPressed: viewAllComparisons, // Navigasi ke list_compare.dart
                          child: Text("View All Comparison"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                        ),
                        ElevatedButton(
                          onPressed: saveComparison,
                          child: Text("Save Comparison"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TableRow _buildTableRow(String spec, String? car1Value, String? car2Value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(spec, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(car1Value ?? "-"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(car2Value ?? "-"),
        ),
      ],
    );
  }
}
