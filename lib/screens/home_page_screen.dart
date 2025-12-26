import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/apartment_card.dart';
import '../services/apartment_service.dart';
import '../models/apartment_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String routeName = '/home';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: 40),
          // SearchFiltersWidget(
          //   onLocationSelected: (gov, city) {
          //     // send to backend
          //   },
          //   onBedsSelected: (beds) {},
          //   onBathsSelected: (baths) {},
          //   onAreaSelected: (min, max) {},
          //   onPriceSelected: (min, max) {},
          // ),
          // Expanded(
          //   child: ListView.builder(
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: AppSizes.paddingMedium,
          //       vertical: AppSizes.paddingSmall,
          //     ),
          //     itemCount: _apartments.length,
          //     itemBuilder: (context, index) {
          //       return ApartmentCard(apartment: _apartments[index]);
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
