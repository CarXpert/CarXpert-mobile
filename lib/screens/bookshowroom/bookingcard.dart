import 'package:car_xpert/models/booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

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

 
  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.PENDING:
        return Colors.orange;
      case Status.CONFIRMED:
        return Colors.green;
      case Status.CANCELED:
        return Colors.red;
      default:
        return Colors.grey; 
    }
  }

  
  bool _isVisitDateInPastOrToday(String visitDate) {
    final parsedDate = DateFormat('yyyy-MM-dd').parse(visitDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); 
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
          color: Colors.white, 
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!), 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
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

           
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                color: Colors.black,
                thickness: 1,
              ),
            ),

            if (!showLocation) ...[
           
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12.0), 
                  child: Image.asset(
                    'assets/images/${widget.booking.car.brand}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),

         
              _buildInfoRow(
                'Car:',
                '${widget.booking.car.brand}, ${widget.booking.car.carType}, ${widget.booking.car.model}',
              ),
              _buildInfoRow('Visit Date:', visitDate),
              _buildInfoRow('Visit Time:', widget.booking.visitTime),

             
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
                          color: Colors.blue, 
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
                    const SizedBox(height: 16.0), 
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
         
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 18, 
                color: Colors.blue, 
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, 
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis, 
            ),
          ),
        ],
      ),
    );
  }
}
