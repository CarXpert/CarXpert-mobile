import 'dart:convert';

import 'package:flutter/material.dart';

class BookShowroomScreen extends StatefulWidget {
  @override
  _BookShowroomScreenState createState() => _BookShowroomScreenState();
}

class _BookShowroomScreenState extends State<BookShowroomScreen> {
  DateTime selectedDate = DateTime.now();
  bool isBookingFormVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BookShowroom',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Wrap the entire body with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${selectedDate.month} ${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Bookings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isBookingFormVisible) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      'No bookings have been made for this date',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isBookingFormVisible = true;
                    });
                  },
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              BookingForm(
                onCancel: () {
                  setState(() {
                    isBookingFormVisible = false;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BookingForm extends StatefulWidget {
  final VoidCallback onCancel;

  const BookingForm({required this.onCancel, super.key});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  List<String> showrooms = [];
  String? selectedShowroom;

  get http => null;

  @override
  void initState() {
    super.initState();
    fetchShowrooms();
  }

  // Fetch showrooms from Django server
  Future<void> fetchShowrooms() async {
    final response = await http
        .get(Uri.parse('http://your-django-server-url/api/showrooms/'));

    if (response.statusCode == 200) {
      List<String> fetchedShowrooms =
          List<String>.from(json.decode(response.body));
      setState(() {
        showrooms = fetchedShowrooms;
      });
    } else {
      throw Exception('Failed to load showrooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Add SingleChildScrollView for the form
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              onChanged: (value) {
                setState(() {
                  selectedShowroom = value;
                });
              },
              value: selectedShowroom,
              decoration: const InputDecoration(
                hintText: 'Select a showroom',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Location:'),
            DropdownButtonFormField<String>(
              items: ['Location A', 'Location B']
                  .map((location) => DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {},
              decoration: const InputDecoration(
                hintText: 'Select a location',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Car:'),
            DropdownButtonFormField<String>(
              items: ['Car A', 'Car B']
                  .map((car) => DropdownMenuItem<String>(
                        value: car,
                        child: Text(car),
                      ))
                  .toList(),
              onChanged: (value) {},
              decoration: const InputDecoration(
                hintText: 'Select a car',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Visit Date:'),
            TextFormField(
              initialValue: '14/11/2024',
              decoration: const InputDecoration(
                hintText: 'Enter a date',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Visit Time:'),
            TextFormField(
              initialValue: '12:00 PM',
              decoration: const InputDecoration(
                hintText: 'Enter a time',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Notes:'),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Additional information (optional)',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      // Submit booking logic
                    },
                    child: const Text('Submit Booking'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
