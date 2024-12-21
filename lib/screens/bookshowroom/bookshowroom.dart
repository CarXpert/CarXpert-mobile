import 'dart:convert';

import 'package:car_xpert/models/booking.dart';
import 'package:car_xpert/screens/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:car_xpert/screens/bookshowroom/bookingcard.dart';

class BookShowroomScreen extends StatefulWidget {
  @override
  _BookShowroomScreenState createState() => _BookShowroomScreenState();
}

class _BookShowroomScreenState extends State<BookShowroomScreen> {
  DateTime selectedDate = DateTime.now();
  List<Booking> bookings = [];
  Booking? currentEditingData;
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
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/json/",
      );

      if (response != null) {
        setState(() {
          bookings = bookingFromJson(json.encode(response));
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

  Future<void> deleteBooking(String bookingId) async {
    final url = Uri.parse(
        'https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/delete_booking_flutter/$bookingId/');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        print("Booking deleted successfully.");
        setState(() {
          isLoading = true;
        });
        await fetchBookings();
      } else {
        print("Failed to delete booking: ${response.body}");
      }
    } catch (e) {
      print("Error during delete request: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper function to get bookings for the selected date
  List<Booking> getBookingsForSelectedDate() {
    return bookings
        .where((booking) =>
            DateTime.parse(booking.visitDate).day == selectedDate.day &&
            DateTime.parse(booking.visitDate).month == selectedDate.month &&
            DateTime.parse(booking.visitDate).year == selectedDate.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsForSelectedDate = getBookingsForSelectedDate();

    final normalizedSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final normalizedNow = DateTime.now();
    final normalizedNowDate =
        DateTime(normalizedNow.year, normalizedNow.month, normalizedNow.day);

    final isPast = normalizedSelectedDate.isBefore(normalizedNowDate);

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
                    TableCalendar(
                      focusedDay: selectedDate,
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      headerStyle: HeaderStyle(
                        titleTextStyle: TextStyle(fontSize: 20),
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.arrow_left),
                        rightChevronIcon: Icon(Icons.arrow_right),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, _) {
                          final hasBooking = bookings.any((booking) {
                            final visitDateString = booking.visitDate as String;
                            final visitDate = DateTime.parse(visitDateString);
                            final normalizedVisitDate = DateTime(
                                visitDate.year, visitDate.month, visitDate.day);
                            final normalizedDate =
                                DateTime(date.year, date.month, date.day);
                            return normalizedVisitDate
                                .isAtSameMomentAs(normalizedDate);
                          });
                          final normalizedDate =
                              DateTime(date.year, date.month, date.day);
                          final normalizedNow = DateTime.now();
                          final normalizedNowDate = DateTime(normalizedNow.year,
                              normalizedNow.month, normalizedNow.day);
                          final isPast =
                              normalizedDate.isBefore(normalizedNowDate);

                          Color dateColor = Colors.white;
                          if (hasBooking) {
                            dateColor =
                                isPast ? Colors.blue[800]! : Colors.blue;
                          } else if (isPast) {
                            dateColor =
                                const Color.fromARGB(255, 215, 220, 225);
                          }

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: dateColor,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: hasBooking || isPast
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, date, _) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      selectedDayPredicate: (day) =>
                          isSameDay(day, selectedDate),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          selectedDate = selectedDay;
                          isBookingFormVisible = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    if (!isBookingFormVisible && !isPast)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom:
                                  40.0), // Adjust vertical padding for top and bottom space
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                final request = context.read<CookieRequest>();
                                if (!request.loggedIn) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                  );
                                  return;
                                }
                                isBookingFormVisible = true;
                                currentEditingData = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal:
                                      40.0), // Increase padding for a bigger button
                              backgroundColor: Colors.blue,
                              textStyle: const TextStyle(
                                  fontSize:
                                      20), // Increase font size for a bigger button label
                            ),
                            child: const Text(
                              'Book Appointment',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      "Bookings for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isBookingFormVisible) ...[
                      if (bookingsForSelectedDate.isNotEmpty)
                        ...bookingsForSelectedDate.map(
                          (booking) => BookingCard(
                            booking: booking,
                            onEdit: () {
                              setState(() {
                                isBookingFormVisible = true;
                                currentEditingData = booking;
                              });
                            },
                            onDelete: () => deleteBooking(booking.id),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(25.0),
                          child: Center(
                            child: Text(
                              'No bookings found for this date.',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                    ] else
                      BookingForm(
                        selectedDate: selectedDate,
                        key: ValueKey(selectedDate),
                        isEditing: currentEditingData != null,
                        editingData: currentEditingData,
                        onCancel: () {
                          setState(() {
                            isBookingFormVisible = false;
                            currentEditingData = null;
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
  final DateTime selectedDate;
  final bool isEditing;
  final Booking? editingData;

  const BookingForm({
    required this.onCancel,
    required this.selectedDate,
    this.isEditing = false,
    this.editingData,
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

    if (widget.isEditing && widget.editingData != null) {
      final editingData = widget.editingData!;
      selectedShowroom = editingData.showroom.name;
      selectedLocation = editingData.showroom.id;
      selectedCarId = editingData.car.id;

      final visitTimeString = editingData.visitTime as String;
      final visitTime = DateFormat('HH:mm:ss').parse(visitTimeString);
      final formattedTime = DateFormat.jm().format(visitTime);

      timeController.text = formattedTime;
      notesController.text = editingData.notes!;

      fetchLocations(selectedShowroom!);
      fetchCars(selectedLocation!);
    } else {
      setState(() {
        selectedShowroom = null;
        locations = [];
        selectedLocation = null;
        cars = [];
        selectedCarId = null;
      });
    }
  }

  Future<void> fetchShowrooms() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/get-showrooms/",
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
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/get_locations/$showroomName/",
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
        "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/get_cars/$locationId/",
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
              isExpanded: true,
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
              isExpanded: true,
              items: locations
                  .map((location) => DropdownMenuItem<String>(
                        value: location['id'],
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
              isExpanded: true,
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
              initialValue: '${widget.selectedDate.toLocal()}'.split(' ')[0],
              decoration: const InputDecoration(
                hintText: 'Selected visit date',
              ),
              enabled: false,
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
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final formData = <String, String>{
                        "showroom_id": selectedLocation.toString(),
                        "car_id": selectedCarId.toString(),
                        "visit_date":
                            widget.selectedDate.toIso8601String().split('T')[0],
                        "visit_time": timeController.text,
                        "notes": notesController.text,
                        if (widget.editingData != null)
                          "booking_id": widget.editingData!.id.toString()
                      };

                      final String url = widget.editingData == null
                          ? "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/create_booking_flutter/"
                          : "https://khoirul-azmi-carxpert.pbp.cs.ui.ac.id/bookshowroom/edit_booking_flutter/";

                      try {
                        final response = await request.postJson(
                          url,
                          jsonEncode(formData),
                        );

                        if (response["error"] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Error: ${response['error']}")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Booking successfully saved!")),
                          );
                          widget.onCancel();
                          if (context.mounted) {
                            final parentState = context.findAncestorStateOfType<
                                _BookShowroomScreenState>();
                            if (parentState != null) {
                              await parentState.fetchBookings();
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
                            content:
                                Text("Please complete all required fields.")),
                      );
                    }
                  },
                  child: Text(widget.editingData == null
                      ? 'Submit Booking'
                      : 'Edit Booking'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 15.0,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                )),
                const SizedBox(width: 16.0),
                Expanded(
                    child: ElevatedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 15.0,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
