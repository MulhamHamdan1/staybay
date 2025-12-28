// import 'package:flutter/material.dart';
// import 'package:staybay/models/apartment_model.dart';
// import 'package:staybay/services/get_my_booking_service.dart';
// import 'package:staybay/widgets/booking_card.dart';
// import 'package:staybay/widgets/compact_apartment_card.dart';

// class BookingsScreen extends StatefulWidget {
//   static const routeName = '/bookingsRout';
//   const BookingsScreen({super.key});

//   @override
//   State<BookingsScreen> createState() => _BookingsScreenState();
// }

// class _BookingsScreenState extends State<BookingsScreen> {
//   late Future<List<Apartment>> future;
//   //TODO waiting for hamza
//   @override
//   void initState() {
//     future = GetMyBookingService.getMyBooking();
//     super.initState();
//   }

//   Future<void> _refreshMyBooking() async {
//     setState(() {
//       future = GetMyBookingService.getMyBooking();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Bookings'), centerTitle: true),
//       body: FutureBuilder<List<Apartment>>(
//         future: future,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('oops Error: ${snapshot.error}'));
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasData) {
//             var favorites = snapshot.data!;
//             if (favorites.isEmpty) {
//               return RefreshIndicator(
//                 onRefresh: _refreshMyBooking,
//                 child: ListView(
//                   children: [
//                     const SizedBox(height: 32),
//                     Icon(
//                       Icons.bookmark_outline,
//                       size: 80,
//                       color: theme.colorScheme.primary,
//                     ),
//                     const SizedBox(height: 16),
//                     Center(
//                       child: Text(
//                         'No bookings yet',
//                         style: theme.textTheme.headlineMedium,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return RefreshIndicator(
//               onRefresh: _refreshMyBooking,
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16.0),
//                 itemCount: favorites.length,
//                 itemBuilder: (context, index) {
//                   var apartment = favorites[index];
//                   return BookedCard(apartment: apartment, onDelete: () {});
//                 },
//               ),
//             );
//           } else {
//             return Center(
//               child: Text(
//                 'No bookings yet!',
//                 style: theme.textTheme.headlineMedium,
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
