import 'package:flutter/material.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/models/book_model.dart';
import 'package:staybay/screens/booking_details_screen.dart';

class BookedCard extends StatefulWidget {
  final BookModel book;

  const BookedCard({super.key, required this.book});

  @override
  State<BookedCard> createState() => _BookedCardState();
}

class _BookedCardState extends State<BookedCard> {
  final Map<String, Color> statusColors = {
    'pending': Colors.orange, // waiting for action
    'approved': Colors.green, // approved
    'rejected': Colors.red, // rejected
    'cancelled': Colors.grey, // cancelled
    'completed': Colors.blue, // completed successfully
    'started': Colors.lightBlue, // started
    'finished': Colors.teal, // finished process
    'failed': Colors.deepOrange, // failed
  };
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  BookingDetailsScreen(apartment: widget.book.apartment),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  widget.book.apartment.imagePath,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 160, color: Colors.grey[300]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.book.apartment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          widget.book.apartment.location!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          "total : ${widget.book.totalePrice.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        // Text(
                        //   '\$${widget.book.apartment.pricePerNight.toStringAsFixed(0)} / night',
                        //   style: const TextStyle(fontWeight: FontWeight.w600),
                        // ),
                        Spacer(),
                        ...List.generate(5, (index) {
                          return Icon(
                            index < int.parse(widget.book.apartment.rating)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        Text(
                          '${widget.book.apartment.rating} (${widget.book.apartment.ratingCount} reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          'start : ${widget.book.startDate}',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Spacer(),
                        Text(
                          'end: ${widget.book.endDate}',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Status: ${widget.book.status}',
                          style: TextStyle(
                            color: statusColors['approved'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        widget.book.userCanPay
                            ? TextButton(onPressed: () {}, child: Text('pay'))
                            : Text(''),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
