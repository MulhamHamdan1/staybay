import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/services/get_favorite_apartment_service.dart';
import '../models/apartment_model.dart';
import '../widgets/compact_apartment_card.dart';

class FavoritesScreen extends StatefulWidget {
  static const String routeName = 'favorites';
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, dynamic> get locale =>
      context.watch<LocaleCubit>().state.localizedStrings['favorites'];

  late Future<List<Apartment>> future;
  @override
  void initState() {
    future = GetApartmentService.getFavorites();
    super.initState();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      future = GetApartmentService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale['title'] ?? 'My Favorites'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Apartment>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${locale['error']}${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var favorites = snapshot.data!;
            if (favorites.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshFavorites,
                child: ListView(
                  children: [
                    const SizedBox(height: 32),
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        locale['noItems'] ?? 'No Favorite items yet',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshFavorites,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  var apartment = favorites[index];
                  return CompactApartmentCard(
                    apartment: apartment,
                    edit: false,
                  );
                },
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshFavorites,
              child: ListView(
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      locale['noItems'] ?? 'No Favorite items yet',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
