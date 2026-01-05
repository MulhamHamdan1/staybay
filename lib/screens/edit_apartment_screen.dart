import 'dart:io';
import 'dart:developer' as dev; 
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/models/city_model.dart';
import 'package:staybay/models/governorate_model.dart';
import 'package:staybay/services/update_apartment_service.dart';
import 'package:staybay/services/get_governorates_and_cities_service.dart';
import 'package:staybay/widgets/app_bottom_nav_bar.dart';

class EditApartmentScreen extends StatefulWidget {
  static const String routeName = 'edit';
  final Apartment apartment;

  const EditApartmentScreen({super.key, required this.apartment});

  @override
  State<EditApartmentScreen> createState() => _EditApartmentScreenState();
}

class _EditApartmentScreenState extends State<EditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final GetGovernatesAndCities _getService = GetGovernatesAndCities();

  Governorate? selectedGov;
  City? selectedCity;
  List<Governorate> governorates = [];
  List<City> cities = [];

  bool isLoadingInitialData = true;
  bool isLoadingGovs = true;
  bool isLoadingCities = false;
  bool isSaving = false;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _selectedAmenities = [];
  final List<String> _allAmenities = ['wifi', 'pool'];

  File? _pickedCover;
  String? _existingCoverUrl;
  final List<File> _pickedImages = [];
  List<String> _existingImageUrls = [];
  final List<int> _deletedImageIds = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadInitialLocationData();
  }

  void _initializeFields() {
    try {
      final a = widget.apartment;
      _titleController.text = a.title;
      _priceController.text = a.pricePerNight.toString();
      _bedsController.text = a.beds.toString();
      _bathsController.text = a.baths.toString();
      _areaController.text = a.areaSqft.toString();
      _descriptionController.text = a.description;
      _selectedAmenities = List.from(a.amenities);

      _existingCoverUrl = a.imagePath;

      if (a.imagesPaths.isNotEmpty) {
        _existingImageUrls = a.imagesPaths
            .where((path) => path != a.imagePath)
            .toList();
      }
    } catch (e) {
      dev.log("ERROR in _initializeFields: $e");
    }
  }

  Future<void> _loadInitialLocationData() async {
    try {
      final fetchedGovs = await _getService.getGovernorates();
      if (!mounted) return;

      setState(() {
        governorates = fetchedGovs;
        isLoadingGovs = false;
        if (widget.apartment.governorate != null) {
          selectedGov = governorates
              .where((g) => g.id == widget.apartment.governorate?.id)
              .firstOrNull;
        }
      });

      if (selectedGov != null) {
        setState(() => isLoadingCities = true);
        final fetchedCities = await _getService.getCities(selectedGov!.id);
        if (!mounted) return;

        setState(() {
          cities = fetchedCities;
          selectedCity = cities
              .where((c) => c.id == widget.apartment.city?.id)
              .firstOrNull;
          isLoadingCities = false;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) setState(() => isLoadingInitialData = false);
      } else {
        setState(() => isLoadingInitialData = false);
      }
    } catch (e) {
      dev.log("CRASH in _loadInitialLocationData: $e");
      if (mounted) setState(() => isLoadingInitialData = false);
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
      final data = await _getService.getCities(gov.id);
      if (mounted) {
        setState(() {
          cities = data;
          isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingCities = false);
    }
  }

  void _removeExistingGalleryImage(int index) {
    setState(() {
      if (widget.apartment.imagesIDs != null) {
        int idToPull = index + 1;
        if (idToPull < widget.apartment.imagesIDs!.length) {
          int imageId = widget.apartment.imagesIDs![idToPull];
          _deletedImageIds.add(imageId);
          dev.log("Image marked for deletion: $imageId");
        }
      }
      _existingImageUrls.removeAt(index);
    });
  }

  void _saveApartment() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedCity == null) {
        _showSnackBar('Please select a city');
        return;
      }
      dev.log('new cover image:  ${_pickedCover?.path} ?? "no image selected"');
      setState(() => isSaving = true);
 
      List<String> newGalleryPaths = _pickedImages.map((e) => e.path).toList();
 
      Apartment updatedApartment = Apartment(
        id: widget.apartment.id,
        title: _titleController.text,
        pricePerNight: double.tryParse(_priceController.text) ?? 0.0,
        imagePath: _pickedCover?.path ?? _existingCoverUrl!,  
        rating: widget.apartment.rating,
        ratingCount: widget.apartment.ratingCount,
        beds: int.tryParse(_bedsController.text) ?? 0,
        baths: int.tryParse(_bathsController.text) ?? 0,
        areaSqft: double.tryParse(_areaController.text) ?? 0.0,
        description: _descriptionController.text,
        imagesPaths: [..._existingImageUrls, ...newGalleryPaths],
        amenities: _selectedAmenities,
        city: selectedCity,
        governorate: selectedGov,
        imagesIDs: widget.apartment.imagesIDs,
      );

      try {
        final response = await UpdateApartmentService.updateApartment(
          context: context,
          apartment: updatedApartment,
          cityId: selectedCity!.id,
          deletedImageIds: _deletedImageIds, 
          newCoverPath: _pickedCover?.path,
          newGalleryPaths: newGalleryPaths,
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppBottomNavBar.routeName,
            (route) => false,
          );
        } else {
          _showSnackBar("Failed: ${response?.data['message'] ?? 'Error'}");
        }
      } catch (e) {
        _showSnackBar("Connection error");
      } finally {
        if (mounted) setState(() => isSaving = false);
      }
    }
  }

  void _showSnackBar(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    if (isLoadingInitialData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Apartment')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _sectionHeader("Cover Image"),
                  _coverPickerUI(),
                  const SizedBox(height: 20),
                  _sectionHeader("Gallery Images"),
                  _galleryPickerUI(),
                  const SizedBox(height: 16),
                  _field(_titleController, 'Title', Icons.home),
                  _buildLocationSelectors(),
                  _field(
                    _priceController,
                    'Price',
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
                  _amenitiesSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveApartment,
                      child: const Text('Update Apartment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSelectors() {
    return Column(
      children: [
        _buildFilterRow(
          label: 'المحافظة',
          value: selectedGov?.name,
          child: isLoadingGovs
              ? const LinearProgressIndicator()
              : DropdownButton<Governorate>(
                  isExpanded: true,
                  value: governorates.contains(selectedGov)
                      ? selectedGov
                      : null,
                  items: governorates
                      .map(
                        (g) => DropdownMenuItem(value: g, child: Text(g.name)),
                      )
                      .toList(),
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
                  value: (cities.isNotEmpty && cities.contains(selectedCity))
                      ? selectedCity
                      : null,
                  items: cities
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedCity = v),
                ),
        ),
      ],
    );
  }

  Widget _networkImageWrapper(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.red),
      ),
    );
  }

  Widget _coverPickerUI() {
    return GestureDetector(
      onTap: () async {
        final img = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (img != null) setState(() => _pickedCover = File(img.path));
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: _pickedCover != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_pickedCover!.path), fit: BoxFit.cover),
              )
            : (_existingCoverUrl != null)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _networkImageWrapper(_existingCoverUrl!),
              )
            : const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _galleryPickerUI() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._existingImageUrls.asMap().entries.map(
            (e) => _galleryTile(
              _networkImageWrapper(e.value),
              () => _removeExistingGalleryImage(e.key),
            ),
          ),
          ..._pickedImages.asMap().entries.map(
            (e) => _galleryTile(
              Image.file(File(e.value.path), fit: BoxFit.cover),
              () => setState(() => _pickedImages.removeAt(e.key)),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final imgs = await ImagePicker().pickMultiImage(imageQuality: 70);
              if (imgs.isNotEmpty) {
                setState(
                  () => _pickedImages.addAll(imgs.map((img) => File(img.path))),
                );
              }
             
            },
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryTile(Widget img, VoidCallback onRem) => Stack(
    children: [
      Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
      ),
      Positioned(
        right: 12,
        top: 4,
        child: GestureDetector(
          onTap: onRem,
          child: const CircleAvatar(
            radius: 10,
            backgroundColor: Colors.red,
            child: Icon(Icons.close, size: 12, color: Colors.white),
          ),
        ),
      ),
    ],
  );
  Widget _sectionHeader(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );
  Widget _buildFilterRow({
    required String label,
    required String? value,
    required Widget child,
  }) => Padding(
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
  Widget _amenitiesSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Amenities',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      ..._allAmenities.map(
        (a) => CheckboxListTile(
          value: _selectedAmenities.contains(a),
          title: Text(a),
          onChanged: (v) => setState(
            () => v! ? _selectedAmenities.add(a) : _selectedAmenities.remove(a),
          ),
        ),
      ),
    ],
  );
  Widget _field(
    TextEditingController c,
    String l,
    IconData i, {
    TextInputType inputType = TextInputType.text,
    int maxlines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      keyboardType: inputType,
      maxLines: maxlines,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
