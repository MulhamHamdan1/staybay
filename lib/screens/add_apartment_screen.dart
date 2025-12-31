import 'dart:io';
import 'package:dio/src/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/models/city_model.dart';
import 'package:staybay/models/governorate_model.dart';
import 'package:staybay/services/add_apartment_service.dart';
import 'package:staybay/services/get_governorates_and_cities_service.dart';
import 'package:staybay/services/update_apartment_service.dart';
import 'package:staybay/widgets/app_bottom_nav_bar.dart';

class AddApartmentScreen extends StatefulWidget {
  static const String routeName = 'add';

  final Apartment? apartmentToEdit;
  const AddApartmentScreen({super.key, this.apartmentToEdit});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final GetGovernatesAndCities _getGovernatesAndCities =
      GetGovernatesAndCities();

  Governorate? selectedGov;
  City? selectedCity;
  List<Governorate> governorates = [];
  List<City> cities = [];

  bool isLoadingGovs = true;
  bool isLoadingCities = false;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _allAmenities = ['wifi', 'pool'];
  List<String> _selectedAmenities = [];

  /// ===== IMAGE STATE =====
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _pickedImages = []; // New local images
  final Map<String, Uint8List> _webImageBytes = {};
  List<String> _existingImageUrls = []; // Images already on the server

  @override
  void initState() {
    super.initState();
    _loadGovernorates();

    if (widget.apartmentToEdit != null) {
      final apartment = widget.apartmentToEdit!;
      _existingImageUrls = List.from(apartment.imagesPaths);
      _titleController.text = apartment.title;
      _priceController.text = apartment.pricePerNight.toString();
      _bedsController.text = apartment.beds.toString();
      _bathsController.text = apartment.baths.toString();
      _areaController.text = apartment.areaSqft.toString();
      _descriptionController.text = apartment.description;
      _selectedAmenities = List.from(apartment.amenities);
    }
  }

  Future<void> _loadGovernorates() async {
    try {
      final data = await _getGovernatesAndCities.getGovernorates();
      if (!mounted) return;

      setState(() {
        governorates = data;
        isLoadingGovs = false;
        if (widget.apartmentToEdit != null &&
            widget.apartmentToEdit!.governorate != null) {
          selectedGov = governorates.firstWhere(
            (g) => g.id == widget.apartmentToEdit!.governorate!.id,
            orElse: () => governorates.first,
          );
          _onGovernorateChanged(selectedGov);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingGovs = false);
    }
  }

  Future<void> _onGovernorateChanged(Governorate? gov) async {
    if (gov == null) return;
    setState(() {
      selectedGov = gov;
      selectedCity = null;
      cities = [];
      isLoadingCities = true;
    });

    try {
      final data = await _getGovernatesAndCities.getCities(gov.id);
      if (!mounted) return;

      setState(() {
        cities = data;
        isLoadingCities = false;
        if (widget.apartmentToEdit != null &&
            widget.apartmentToEdit!.city != null) {
          var match = cities.where(
            (c) => c.id == widget.apartmentToEdit!.city!.id,
          );
          if (match.isNotEmpty) selectedCity = match.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingCities = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// ===== IMAGE PICKER & PREVIEW =====
  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;

    if (kIsWeb) {
      for (final img in images) {
        _webImageBytes[img.name] = await img.readAsBytes();
      }
    }
    setState(() => _pickedImages.addAll(images));
  }

  void _removeImageAt(int index) {
    final removed = _pickedImages.removeAt(index);
    if (kIsWeb) _webImageBytes.remove(removed.name);
    setState(() {});
  }

  void _removeExistingImageAt(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }

  Widget _imagesPreview() {
    final totalItems = _existingImageUrls.length + _pickedImages.length + 1;

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalItems,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // Add Button
          if (index == totalItems - 1) {
            return InkWell(
              onTap: _pickImages,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.add_a_photo, color: Colors.blue),
              ),
            );
          }

          // Existing Images (URLs)
          if (index < _existingImageUrls.length) {
            return _buildImageStack(
              image: Image.network(
                _existingImageUrls[index],
                fit: BoxFit.cover,
              ),
              onDelete: () => _removeExistingImageAt(index),
            );
          }

          // Newly Picked Images (Files)
          final pickedIndex = index - _existingImageUrls.length;
          final image = _pickedImages[pickedIndex];
          return _buildImageStack(
            image: kIsWeb
                ? Image.memory(_webImageBytes[image.name]!, fit: BoxFit.cover)
                : Image.file(File(image.path), fit: BoxFit.cover),
            onDelete: () => _removeImageAt(pickedIndex),
          );
        },
      ),
    );
  }

  Widget _buildImageStack({
    required Widget image,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 120, height: 120, child: image),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onDelete,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// ===== SAVE / UPDATE LOGIC =====
  void _saveApartment() async {
    // 1. Combine all images to check if list is empty
    final List<String> combinedImages = [
      ..._existingImageUrls,
      ..._pickedImages.map((e) => e.path).toList(),
    ];

    if (_formKey.currentState?.validate() ?? false) {
      if (selectedGov == null || selectedCity == null) {
        _showSnackBar('Please select governorate and city');
        return;
      }

      if (combinedImages.isEmpty) {
        _showSnackBar('Please add at least one image');
        return;
      }

      // Create Apartment object with combined images
      Apartment apartment = Apartment(
        title: _titleController.text,
        pricePerNight: double.parse(_priceController.text),
        imagePath: combinedImages.first, // Main display image
        rating: widget.apartmentToEdit?.rating ?? '0',
        ratingCount: widget.apartmentToEdit?.ratingCount ?? 0,
        beds: int.parse(_bedsController.text),
        baths: int.parse(_bathsController.text),
        areaSqft: double.parse(_areaController.text),
        description: _descriptionController.text,
        imagesPaths: combinedImages, // Send all (old + new)
        amenities: _selectedAmenities,
      );

      Response<dynamic>? response;
      if (widget.apartmentToEdit == null) {
        response = await AddApartmentService.addApartment(
          context: context,
          apartment: apartment,
          cityId: selectedCity!.id,
        );
      } else {
        // Pass the original ID for updating
        apartment.id = widget.apartmentToEdit!.id;
        response = await UpdateApartmentService.updateApartment(
          context: context,
          apartment: apartment,
          cityId: selectedCity!.id,
          // deletedImageIds:
        );
      }

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppBottomNavBar.routeName, (_) => false);
      }
    } else {
      _showSnackBar('Please fill all required fields');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// ===== UI COMPONENTS =====

  Widget _buildFilterRow({
    required String label,
    required String? value,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                child,
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                value ?? '-',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._allAmenities.map((amenity) {
          return CheckboxListTile(
            value: _selectedAmenities.contains(amenity),
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(
              children: [
                Icon(_getAmenityIcon(amenity), size: 20),
                const SizedBox(width: 8),
                Text(amenity),
              ],
            ),
            onChanged: (value) {
              setState(() {
                value == true
                    ? _selectedAmenities.add(amenity)
                    : _selectedAmenities.remove(amenity);
              });
            },
          );
        }),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    int maxlines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxlines,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.apartmentToEdit == null ? 'Add Apartment' : 'Edit Apartment',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _imagesPreview(),
              const SizedBox(height: 16),
              _field(_titleController, 'Title', Icons.home),
              _buildFilterRow(
                label: 'المحافظة',
                value: selectedGov?.name,
                child: isLoadingGovs
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : DropdownButton<Governorate>(
                        isExpanded: true,
                        hint: const Text('اختر محافظة'),
                        value: selectedGov,
                        items: governorates.map((gov) {
                          return DropdownMenuItem(
                            value: gov,
                            child: Text(gov.name),
                          );
                        }).toList(),
                        onChanged: _onGovernorateChanged,
                      ),
              ),
              _buildFilterRow(
                label: 'المدينة',
                value: selectedCity?.name,
                child: isLoadingCities
                    ? const LinearProgressIndicator()
                    : DropdownButton<City>(
                        isExpanded: true,
                        hint: Text(
                          selectedGov == null
                              ? 'اختر محافظة أولاً'
                              : 'اختر مدينة',
                        ),
                        value: selectedCity,
                        items: cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city.name),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedCity = val),
                      ),
              ),
              _field(
                _priceController,
                'Price per night',
                Icons.attach_money,
                inputType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _bedsController,
                      'Beds',
                      Icons.bed,
                      inputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _bathsController,
                      'Baths',
                      Icons.bathtub,
                      inputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _field(
                _areaController,
                'Area',
                Icons.square_foot,
                inputType: TextInputType.number,
              ),
              _field(
                _descriptionController,
                'Description',
                Icons.description,
                maxlines: 3,
              ),
              const SizedBox(height: 16),
              _amenitiesSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveApartment,
                  child: const Text('Save Apartment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    if (amenity.toLowerCase() == 'wifi') return Icons.wifi;
    if (amenity.toLowerCase() == 'pool') return Icons.pool;
    return Icons.check_circle_outline;
  }
}
