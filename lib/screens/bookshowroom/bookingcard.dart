import 'package:car_xpert/models/booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date parsing and comparison

class BookingCard extends StatefulWidget {
  final Booking booking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool showLocation = false;

  // Helper function to get color based on status
  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.PENDING:
        return Colors.orange;
      case Status.CONFIRMED:
        return Colors.green;
      case Status.CANCELED:
        return Colors.red;
      default:
        return Colors.grey; // Fallback color
    }
  }

  // Helper function to check if visit date is in the past
  bool _isVisitDateInPastOrToday(String visitDate) {
    final parsedDate = DateFormat('yyyy-MM-dd').parse(visitDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Strip off time
    return parsedDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final visitDate = widget.booking.visitDate;
    final isPastDate = _isVisitDateInPastOrToday(visitDate);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, // Set background to white
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!), // Optional border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Showroom Name and Status in a Row
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Showroom Name
                  Flexible(
                    child: Text(
                      'Showroom: ${widget.booking.showroom.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Status Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.booking.status),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      widget.booking.status
                          .toString()
                          .split('.')
                          .last
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Black line between Showroom Name and Car Image
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                color: Colors.black,
                thickness: 1,
              ),
            ),

            if (!showLocation) ...[
              // Car Image with rounded corners
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12.0), // Make image rounded
                  child: Image.network(
                    'assets/images/${widget.booking.car.brand}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),

              // Information Fields
              _buildInfoRow(
                'Car:',
                '${widget.booking.car.brand}, ${widget.booking.car.carType}, ${widget.booking.car.model}',
              ),
              _buildInfoRow('Visit Date:', visitDate),
              _buildInfoRow('Visit Time:', widget.booking.visitTime),

              // Notes (if any)
              if (widget.booking.notes != null &&
                  widget.booking.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Blue text for description
                        ),
                      ),
                      Text(
                        widget.booking.notes ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              // Action buttons (Edit, Delete, Location)
              if (!isPastDate)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.location_on, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            showLocation = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ] else ...[
              // Location View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Gmaps.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Location: ${widget.booking.showroom.location}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showLocation = false;
                        });
                      },
                      child: const Text('Back'),
                    ),
                    const SizedBox(height: 16.0), // Added space here
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String description, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description in blue outlined rectangle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 18, // Increased font size for description
                color: Colors.blue, // Blue text for description
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Right-aligned value
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // Align text to the right
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis, // Truncate long text
            ),
          ),
        ],
      ),
    );
  }
}
