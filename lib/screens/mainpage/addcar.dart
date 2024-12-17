// lib/screens/mainpage/addcar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();

  // Kontroler untuk setiap field
  final TextEditingController _showroomNameController = TextEditingController();
  final TextEditingController _showroomLocationController = TextEditingController();
  final TextEditingController _showroomRegencyController = TextEditingController();

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController(); // Ubah jadi text field
  String? _model; // Dropdown
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String? _transmission; // Dropdown
  String? _fuelType; // Dropdown
  final TextEditingController _doorsController = TextEditingController();
  final TextEditingController _cylinderSizeController = TextEditingController();
  final TextEditingController _cylinderTotalController = TextEditingController();
  bool _turbo = false;
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _priceCashController = TextEditingController();
  final TextEditingController _priceCreditController = TextEditingController();
  final TextEditingController _pkbValueController = TextEditingController();
  final TextEditingController _pkbBaseController = TextEditingController();
  DateTime? _stnkDate;
  DateTime? _levyDate;
  final TextEditingController _swdklljController = TextEditingController();
  final TextEditingController _totalLevyController = TextEditingController();

  // Data untuk dropdown
  final List<String> _models = [
    'SEDAN',
    'SUV',
    'MPV',
    'MINIVAN',
    'MINIBUS',
    'MICRO/MINIBUS',
    'JEEP',
    'JEEP L.C.HDTP',
    'JEEP S.C.HDTP',
  ];

  final List<String> _transmissions = [
    'manual',
    'automatic',
  ];

  final List<String> _fuelTypes = [
    'Gasoline',
    'Diesel',
  ];

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context, bool isStnk) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStnk) {
          _stnkDate = picked;
        } else {
          _levyDate = picked;
        }
      });
    }
  }

  // Fungsi untuk memformat tanggal ke 'YYYY-MM-DD'
  String _formatDateForDjango(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  // Fungsi untuk menambahkan mobil
  void _addCar() async {
    if (_formKey.currentState!.validate()) {
      if (_model == null || _transmission == null || _fuelType == null || _stnkDate == null || _levyDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan lengkapi semua field yang diperlukan.")),
        );
        return;
      }

      final request = context.read<CookieRequest>();
      // Pastikan kita mengirim showroom_name, showroom_location, showroom_regency
      final response = await request.post("http://127.0.0.1:8000/add_car/", {
        'showroom_name': _showroomNameController.text,
        'showroom_location': _showroomLocationController.text,
        'showroom_regency': _showroomRegencyController.text,
        'brand': _brandController.text,
        'car_type': _carTypeController.text, // Ambil dari text field
        'model': _model!,
        'color': _colorController.text,
        'year': _yearController.text,
        'transmission': _transmission!,
        'fuel_type': _fuelType!,
        'doors': _doorsController.text,
        'cylinder_size': _cylinderSizeController.text,
        'cylinder_total': _cylinderTotalController.text,
        'turbo': _turbo ? 'true' : 'false',
        'mileage': _mileageController.text,
        'license_plate': _licensePlateController.text,
        'price_cash': _priceCashController.text,
        'price_credit': _priceCreditController.text,
        'pkb_value': _pkbValueController.text,
        'pkb_base': _pkbBaseController.text,
        'stnk_date': _formatDateForDjango(_stnkDate!),
        'levy_date': _formatDateForDjango(_levyDate!),
        'swdkllj': _swdklljController.text,
        'total_levy': _totalLevyController.text,
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mobil berhasil ditambahkan.")),
        );
        Navigator.pop(context);
      } else {
        // Tampilkan pesan error yang lebih spesifik jika tersedia
        String errorMessage = "Terjadi kesalahan";
        if (response['error'] != null) {
          errorMessage = response['error'];
        } else if (response['errors'] != null) {
          // Jika ada error dari form Django, tampilkan semua error
          Map<String, dynamic> errors = response['errors'];
          List<String> errorList = [];
          errors.forEach((key, value) {
            errorList.add("$key: ${value.join(', ')}");
          });
          errorMessage = errorList.join('\n');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan mobil: $errorMessage")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Showroom Name
              TextFormField(
                controller: _showroomNameController,
                decoration: const InputDecoration(
                  labelText: 'Showroom Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Showroom Name tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Showroom Location
              TextFormField(
                controller: _showroomLocationController,
                decoration: const InputDecoration(
                  labelText: 'Showroom Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Showroom Location tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Showroom Regency
              TextFormField(
                controller: _showroomRegencyController,
                decoration: const InputDecoration(
                  labelText: 'Showroom Regency',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Showroom Regency tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Brand
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Brand tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Car Type -> Jadi input bebas
              TextFormField(
                controller: _carTypeController,
                decoration: const InputDecoration(
                  labelText: 'Car Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Car Type tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Model
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                value: _model,
                items: _models
                    .map((model) => DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _model = value;
                  });
                },
                validator: (value) => value == null ? 'Silakan pilih model' : null,
              ),
              const SizedBox(height: 16.0),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Color tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Year
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Year tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Year harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Transmission
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Transmission',
                  border: OutlineInputBorder(),
                ),
                value: _transmission,
                items: _transmissions
                    .map((trans) => DropdownMenuItem(
                          value: trans,
                          child: Text(trans.capitalize()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _transmission = value;
                  });
                },
                validator: (value) => value == null ? 'Silakan pilih transmission' : null,
              ),
              const SizedBox(height: 16.0),

              // Fuel Type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                  border: OutlineInputBorder(),
                ),
                value: _fuelType,
                items: _fuelTypes
                    .map((fuel) => DropdownMenuItem(
                          value: fuel,
                          child: Text(fuel),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _fuelType = value;
                  });
                },
                validator: (value) => value == null ? 'Silakan pilih fuel type' : null,
              ),
              const SizedBox(height: 16.0),

              // Doors
              TextFormField(
                controller: _doorsController,
                decoration: const InputDecoration(
                  labelText: 'Doors',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Doors tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Doors harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Cylinder Size
              TextFormField(
                controller: _cylinderSizeController,
                decoration: const InputDecoration(
                  labelText: 'Cylinder Size (cc)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cylinder Size tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Cylinder Size harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Cylinder Total
              TextFormField(
                controller: _cylinderTotalController,
                decoration: const InputDecoration(
                  labelText: 'Cylinder Total',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cylinder Total tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Cylinder Total harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Turbo
              SwitchListTile(
                title: const Text('Turbo'),
                value: _turbo,
                onChanged: (bool value) {
                  setState(() {
                    _turbo = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Mileage
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mileage tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Mileage harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // License Plate
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'License Plate tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Price Cash
              TextFormField(
                controller: _priceCashController,
                decoration: const InputDecoration(
                  labelText: 'Price Cash',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price Cash tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Price Cash harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Price Credit
              TextFormField(
                controller: _priceCreditController,
                decoration: const InputDecoration(
                  labelText: 'Price Credit',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price Credit tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Price Credit harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // PKB Value
              TextFormField(
                controller: _pkbValueController,
                decoration: const InputDecoration(
                  labelText: 'PKB Value',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'PKB Value tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'PKB Value harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // PKB Base
              TextFormField(
                controller: _pkbBaseController,
                decoration: const InputDecoration(
                  labelText: 'PKB Base',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'PKB Base tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'PKB Base harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // STNK Expiry Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _stnkDate == null
                          ? 'STNK Expiry Date: Not selected'
                          : 'STNK Expiry Date: ${_formatDateForDjango(_stnkDate!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Levy Expiry Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _levyDate == null
                          ? 'Levy Expiry Date: Not selected'
                          : 'Levy Expiry Date: ${_formatDateForDjango(_levyDate!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // SWDKLLJ
              TextFormField(
                controller: _swdklljController,
                decoration: const InputDecoration(
                  labelText: 'SWDKLLJ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'SWDKLLJ tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'SWDKLLJ harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Total Levy
              TextFormField(
                controller: _totalLevyController,
                decoration: const InputDecoration(
                  labelText: 'Total Levy',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Total Levy tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Total Levy harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // Tombol Submit
              ElevatedButton(
                onPressed: _addCar,
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose semua controller
    _showroomNameController.dispose();
    _showroomLocationController.dispose();
    _showroomRegencyController.dispose();
    _brandController.dispose();
    _carTypeController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _doorsController.dispose();
    _cylinderSizeController.dispose();
    _cylinderTotalController.dispose();
    _mileageController.dispose();
    _licensePlateController.dispose();
    _priceCashController.dispose();
    _priceCreditController.dispose();
    _pkbValueController.dispose();
    _pkbBaseController.dispose();
    _swdklljController.dispose();
    _totalLevyController.dispose();
    super.dispose();
  }
}

// Extension untuk capitalize string
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
