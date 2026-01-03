import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/services/get_favorite_apartment_service.dart';
import 'package:staybay/widgets/compact_apartment_card.dart';

class MyApartmentsScreen extends StatefulWidget {
  static const routeName = 'my-apartments';

  const MyApartmentsScreen({super.key});

  @override
  State<MyApartmentsScreen> createState() => _MyApartmentsScreenState();
}

class _MyApartmentsScreenState extends State<MyApartmentsScreen> {
  Map<String, dynamic> get locale =>
      context.watch<LocaleCubit>().state.localizedStrings['myApartments'];

  late Future<List<Apartment>> future;
  @override
  void initState() {
    super.initState();
    future = GetApartmentService.getMy();
  }

  Future<void> _refreshMy() async {
    setState(() {
      future = GetApartmentService.getMy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale['title'] ?? 'My Apartments'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Apartment>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('oops Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var myApartment = snapshot.data!;
            if (myApartment.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshMy,
                child: Center(
                  child: Text(
                    locale['noApartments'] ?? 'No Apartment yet',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: myApartment.length,
              itemBuilder: (context, index) {
                var apartment = myApartment[index];
                return CompactApartmentCard(apartment: apartment, edit: true);
              },
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshMy,
              child: Center(
                child: Text(
                  locale['noApartments'] ?? 'No Apartment yet',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
