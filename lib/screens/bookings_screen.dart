import 'package:flutter/material.dart';
import 'package:staybay/models/book_model.dart';
import 'package:staybay/services/get_my_booking_service.dart';
import 'package:staybay/widgets/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  static const routeName = 'bookingsRoute';

  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<BookModel>> future;

  @override
  void initState() {
    super.initState();
    future = GetMyBookingService.getMyBooking();
  }

  Future<void> _refreshMyBooking() async {
    setState(() {
      future = GetMyBookingService.getMyBooking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), centerTitle: true),
      body: FutureBuilder<List<BookModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshMyBooking,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.bookmark_outline,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'You have no bookings yet',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshMyBooking,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return BookedCard(book: bookings[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
