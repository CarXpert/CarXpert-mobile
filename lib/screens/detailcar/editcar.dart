// editcar.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_xpert/models/carlist.dart';
import 'package:intl/intl.dart';

class EditCarPage extends StatefulWidget {
  final String carId;

  const EditCarPage({required this.carId, super.key});

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  // Kontroler untuk setiap field
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _cylinderSizeController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _stnkDateController = TextEditingController();
  final TextEditingController _levyDateController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _priceCashController = TextEditingController();
  final TextEditingController _priceCreditController = TextEditingController();

  bool _isLoading = false;

  Future<CarEntry> fetchCarDetail() async {
    final response = await http.get(Uri.parse('https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/main/json/'));
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
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    try {
      final car = await fetchCarDetail();
      // Isi controller dengan nilai sekarang
      // Pastikan model, fuel_type dsb diisi dengan nilai yang valid
      _modelController.text = fieldsModelValues.reverse[car.fields.model] ?? '';
      _colorController.text = car.fields.color;
      _yearController.text = car.fields.year.toString();
      _fuelTypeController.text = fuelTypeValues.reverse[car.fields.fuelType] ?? '';
      _cylinderSizeController.text = car.fields.cylinderSize.toString();
      _mileageController.text = car.fields.mileage.toString();
      _licensePlateController.text = car.fields.licensePlate;
      _priceCashController.text = car.fields.priceCash.toString();
      _priceCreditController.text = car.fields.priceCredit.toString();

      // Format tanggal agar dapat ditampilkan di TextField (YYYY-MM-DD)
      final stnkDate = car.fields.stnkDate;
      final levyDate = car.fields.levyDate;
      final dateFormatter = DateFormat('yyyy-MM-dd');
      _stnkDateController.text = dateFormatter.format(stnkDate);
      _levyDateController.text = dateFormatter.format(levyDate);

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading car data: $e")),
      );
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/car/edit/${widget.carId}/');

    // Untuk fuel_type dan model, jika di backend adalah pilihan enumerasi,
    // pastikan untuk mengirimkan nilai yang sesuai (misalnya string asli yang digunakan di backend, bukan label).
    // Di sini diasumsikan bahwa value yang kita tulis sama dengan yang di-backend.

    final response = await http.post(
      url,
      body: {
        'model': _modelController.text,
        'color': _colorController.text,
        'year': _yearController.text,
        'fuel_type': _fuelTypeController.text,
        'cylinder_size': _cylinderSizeController.text,
        'mileage': _mileageController.text,
        'stnk_date': _stnkDateController.text,   // format 'YYYY-MM-DD'
        'levy_date': _levyDateController.text,   // format 'YYYY-MM-DD'
        'license_plate': _licensePlateController.text,
        'price_cash': _priceCashController.text,
        'price_credit': _priceCreditController.text,
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // Berhasil update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car updated successfully.")),
      );
      // Kembali ke halaman detail dan refresh data di halaman sebelumnya
      Navigator.pop(context, true); // Mengembalikan true
    } else {
      // Gagal update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update car. Status: ${response.statusCode}, Body: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Car'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField('Model', _modelController),
                  _buildTextField('Color', _colorController),
                  _buildTextField('Year', _yearController, keyboardType: TextInputType.number),
                  _buildTextField('Fuel Type', _fuelTypeController),
                  _buildTextField('Cylinder Size (cc)', _cylinderSizeController, keyboardType: TextInputType.number),
                  _buildTextField('Mileage (km)', _mileageController, keyboardType: TextInputType.number),
                  _buildTextField('STNK Date (YYYY-MM-DD)', _stnkDateController),
                  _buildTextField('Levy Date (YYYY-MM-DD)', _levyDateController),
                  _buildTextField('License Plate', _licensePlateController),
                  _buildTextField('Price Cash', _priceCashController, keyboardType: TextInputType.number),
                  _buildTextField('Price Credit', _priceCreditController, keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
