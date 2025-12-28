import 'package:flutter/material.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/models/book_model.dart';
import 'package:staybay/widgets/booking_card.dart';
import 'package:staybay/widgets/filter_dialog.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return FilterDialog();
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => BookedCard(
          book: BookModel(
            apartment: Apartment(
              id: "1",
              isFavorite: false,
              location: "location",
              ownerName: "nabil",
              title: "title",
              pricePerNight: 0.0,
              imagePath: "imagePath",
              rating: "1",
              ratingCount: 1,
              beds: 1,
              baths: 1,
              areaSqft: 1,
              description: "description",
              imagesPaths: [],
              amenities: [],
            ),
            startDate: '2026-1-28',
            endDate: "2026-1-28",
            status: "approved",
            totalePrice: 0.0,
            rating: 0.0,
            ratedAt: "ratedAt",
            userCanRate: true,
            isPaid: true,
            userCanPay: true,
            createdAt: "createdAt",
            updateAt: "updateAt",
          ),
        ),
      ),
    );
  }
}
