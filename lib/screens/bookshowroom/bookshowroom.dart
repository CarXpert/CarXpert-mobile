import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class BookShowroomScreen extends StatefulWidget {
  @override
  _BookShowroomScreenState createState() => _BookShowroomScreenState();
}

class _BookShowroomScreenState extends State<BookShowroomScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> showrooms = [];
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  bool isBookingFormVisible = false;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "http://127.0.0.1:8000/bookshowroom/json/",
      );

      if (response != null) {
        setState(() {
          bookings = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load bookings.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  List<Map<String, dynamic>> getBookingsForSelectedDate() {
    return bookings
        .where((booking) =>
            DateTime.parse(booking['visit_date']).day == selectedDate.day &&
            DateTime.parse(booking['visit_date']).month == selectedDate.month &&
            DateTime.parse(booking['visit_date']).year == selectedDate.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsForSelectedDate = getBookingsForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Showroom"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 350,
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (newDate) {
                          setState(() {
                            selectedDate = newDate;
                            isBookingFormVisible = false; // Close the form
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      "Bookings for ${selectedDate.toLocal()}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (bookingsForSelectedDate.isNotEmpty)
                      ...bookingsForSelectedDate.map((booking) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                    'Showroom: ${booking['showroom']['name']}'),
                                subtitle: Text(
                                  'Visit Date: ${booking['visit_date']}\nStatus: ${booking['status']}',
                                ),
                              ),
                            ),
                          ))
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No bookings found for this date.',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (!isBookingFormVisible)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isBookingFormVisible = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Book Appointment',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    if (isBookingFormVisible)
                      BookingForm(
                        selectedDate: selectedDate,
                        key: ValueKey(selectedDate), // Unique key based on date
                        onCancel: () {
                          setState(() {
                            isBookingFormVisible = false;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class BookingForm extends StatefulWidget {
  final VoidCallback onCancel;
  final DateTime selectedDate; // Pass selectedDate from parent widget

  const BookingForm({
    required this.onCancel,
    required this.selectedDate,
    super.key,
  });

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> showrooms = [];
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> cars = [];
  String? selectedShowroom;
  String? selectedLocation;
  String? selectedCarId;
  TextEditingController timeController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchShowrooms();

    setState(() {
      selectedShowroom = null;
      locations = [];
      selectedLocation = null;
      cars = [];
      selectedCarId = null;
    });
  }

  Future<void> fetchShowrooms() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "http://127.0.0.1:8000/bookshowroom/get-showrooms/",
      );

      if (response != null) {
        setState(() {
          showrooms = List<String>.from(
            response.map((item) => '${item['showroom_name']}'),
          );
        });
      } else {
        throw Exception("Failed to load showrooms.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchLocations(String showroomName) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "http://127.0.0.1:8000/bookshowroom/get_locations/$showroomName/",
      );

      if (response != null) {
        setState(() {
          locations = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception("Failed to load locations.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchCars(String locationId) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "http://127.0.0.1:8000/bookshowroom/get_cars/$locationId/",
      );

      if (response != null) {
        setState(() {
          cars = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception("Failed to load cars.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Showroom:'),
            DropdownButtonFormField<String>(
              items: showrooms
                  .map((showroom) => DropdownMenuItem<String>(
                        value: showroom,
                        child: Text(showroom),
                      ))
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  selectedShowroom = value;
                  locations = [];
                  selectedLocation = null;
                  cars = [];
                  selectedCarId = null;
                });
                if (value != null) {
                  await fetchLocations(value);
                }
              },
              value: selectedShowroom,
              decoration: const InputDecoration(
                hintText: 'Select a showroom',
              ),
              validator: (value) =>
                  value == null ? 'Please select a showroom' : null,
            ),
            const SizedBox(height: 16.0),
            const Text('Location:'),
            DropdownButtonFormField<String>(
              items: locations
                  .map((location) => DropdownMenuItem<String>(
                        value: location['id'], // UUID as String
                        child: Text(location['showroom_location']),
                      ))
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  selectedLocation = value;
                  cars = [];
                  selectedCarId = null;
                });
                if (value != null) {
                  await fetchCars(value);
                }
              },
              value: selectedLocation,
              decoration: const InputDecoration(
                hintText: 'Select a location',
              ),
              validator: (value) =>
                  value == null ? 'Please select a location' : null,
            ),
            const SizedBox(height: 16.0),
            const Text('Car:'),
            DropdownButtonFormField<String>(
              items: cars
                  .map((car) => DropdownMenuItem<String>(
                        value: car['id'],
                        child: Text(
                            "${car['brand']}, ${car['car_type']}, ${car['model']}"),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCarId = value;
                });
              },
              value: selectedCarId,
              decoration: const InputDecoration(
                hintText: 'Select a car',
              ),
              validator: (value) =>
                  value == null ? 'Please select a car' : null,
            ),
            const SizedBox(height: 16.0),
            const Text('Visit Date:'),
            TextFormField(
              initialValue: '${widget.selectedDate.toLocal()}'.split(
                  ' ')[0], // Use the selected date from the parent widget
              decoration: const InputDecoration(
                hintText: 'Selected visit date',
              ),
              enabled: false, // Disable editing
            ),
            const SizedBox(height: 16.0),
            const Text('Time:'),
            TextFormField(
              controller: timeController,
              decoration: InputDecoration(
                hintText: 'Select time',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    timeController.text = picked.format(context);
                  });
                }
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select a time'
                  : null,
            ),
            const SizedBox(height: 16.0),
            const Text('Notes:'),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Add any notes',
              ),
              maxLines: 3, // Allow multiple lines for notes
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final formData = <String, String>{
                    "showroom_id": selectedLocation.toString(),
                    "car_id": selectedCarId.toString(),
                    "visit_date":
                        widget.selectedDate.toIso8601String().split('T')[0],
                    "visit_time": timeController.text,
                    "notes": notesController.text,
                  };

                  // Print the form data
                  print("Form Data: $formData");

                  try {
                    final response = await request.postJson(
                        "http://127.0.0.1:8000/bookshowroom/create_booking_flutter/",
                        jsonEncode(formData));

                    if (response["error"] != null) {
                      // Handle server-side errors
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${response['error']}")),
                      );
                    } else {
                      // Booking successful
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Booking successfully created!")),
                      );
                      widget.onCancel(); // Close the form
                      if (context.mounted) {
                        final parentState = context.findAncestorStateOfType<
                            _BookShowroomScreenState>();
                        if (parentState != null) {
                          await parentState.fetchBookings(); // Refresh bookings
                        }
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please complete all required fields.")),
                  );
                }
              },
              child: const Text('Submit Booking'),
            ),
            ElevatedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
