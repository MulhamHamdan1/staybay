import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/models/book_model.dart';
// import 'package:staybay/services/get_my_booking_service.dart';
// import 'package:staybay/widgets/booking_card.dart';
import 'package:staybay/services/get_own_booking_service.dart';
import 'package:staybay/widgets/owner_booking_card.dart';

class OwnerBookingsScreen extends StatefulWidget {
  static const routeName = 'ownerBookingsRoute';

  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  Map<String, dynamic> get locale =>
      context.watch<LocaleCubit>().state.localizedStrings['OwnerBookings'];

  late Future<List<BookModel>> future;

  @override
  void initState() {
    super.initState();
    future = GetOwnBookingService.getMyBooking();
  }

  Future<void> _refreshMyBooking() async {
    setState(() {
      future = GetOwnBookingService.getMyBooking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale['title'] ?? 'Bookings Request'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<BookModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${locale['error'] ?? 'Error: '}${snapshot.error}'),
            );
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
                    Icons.request_page_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      locale['noBookings'] ??
                          'You have no bookings request yet',
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
                return OwnerBookedCard(
                  book: bookings[index],
                  onUpdate: () => _refreshMyBooking(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
