import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/apartment_card.dart';
import '../services/apartment_service.dart';
import '../models/apartment_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Apartment> _apartments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

  Future<void> _fetchApartments() async {
    try {
      final data = await ApartmentService().fetchAllApartments();
      setState(() {
        _apartments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching apartments: $e');
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      title: Text(
        'Discover Your New Home',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
     // appBar: _buildAppBar(context),
      body: Column(
        children: [
          SizedBox(height: 40,),
          SearchFilterBar(searchController: _searchController),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingSmall,
                    ),
                    itemCount: _apartments.length,
                    itemBuilder: (context, index) {
                      return ApartmentCard(apartment: _apartments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
