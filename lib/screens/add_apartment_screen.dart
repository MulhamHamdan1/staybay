import 'package:flutter/material.dart';
import 'package:staybay/models/apartment_model.dart';
import '../app_theme.dart';
import 'home_page_screen.dart';
import '../services/apartment_service.dart';

class AddApartmentScreen extends StatefulWidget {
  static const String routeName = '/add';
  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _beds = TextEditingController();
  final _baths = TextEditingController();
  final _area = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _location, _price, _beds, _baths, _area, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    double _parseDouble(String s) =>
        double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
    int _parseInt(String s) => int.tryParse(s) ?? 0;

    final apt = Apartment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      location: _location.text.trim(),
      pricePerNight: _parseDouble(_price.text),
      imagePath: '', // TODO: set a real image path / upload
      rating: 0.0, // default rating for new listing
      reviewsCount: 0,
      beds: _parseInt(_beds.text),
      baths: _parseInt(_baths.text),
      areaSqft: _parseDouble(_area.text),
      ownerName: '', // TODO: set current user / owner
      amenities: <String>[], // TODO: collect from a multi-select
      description: _desc.text.trim(),
      imagesPaths: <String>[], // TODO: add uploaded image URLs
    );

    // Add the newly created Apartment object to your mock list
    ApartmentService.mockApartments.add(apt);

    // Go back to home (clear stack)
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(HomePage.routeName, (route) => false);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType k = TextInputType.text,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      keyboardType: k,
      maxLines: maxLines,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: _dec(label, icon),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Apartment'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a New Listing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Fill the details below to add your apartment',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _field(_title, 'Apartment Title', Icons.home),
              _field(_location, 'Location', Icons.location_on),
              _field(
                _price,
                'Price per Night',
                Icons.attach_money,
                k: const TextInputType.numberWithOptions(decimal: true),
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _beds,
                      'Beds',
                      Icons.bed,
                      k: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _baths,
                      'Baths',
                      Icons.bathtub,
                      k: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _field(
                _area,
                'Area (sqft)',
                Icons.square_foot,
                k: const TextInputType.numberWithOptions(decimal: true),
              ),
              _field(_desc, 'Description', Icons.description, maxLines: 4),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Apartment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
