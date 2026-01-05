// import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/models/city_model.dart';
import 'package:staybay/models/governorate_model.dart';
import 'package:staybay/services/add_apartment_service.dart';
import 'package:staybay/services/get_governorates_and_cities_service.dart';
import 'package:staybay/widgets/app_bottom_nav_bar.dart';

class AddApartmentScreen extends StatefulWidget {
  static const String routeName = 'add';

  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  Map<String, dynamic> get locale =>
      context.watch<LocaleCubit>().state.localizedStrings['addApartment'];

  final _formKey = GlobalKey<FormState>();
  final GetGovernatesAndCities _getGovernatesAndCities =
      GetGovernatesAndCities();

  Governorate? selectedGov;
  City? selectedCity;
  List<Governorate> governorates = [];
  List<City> cities = [];

  bool isLoadingGovs = true;
  bool isLoadingCities = false;
  bool isSaving = false;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> get _allAmenities => [
    locale['amenities']['wifi'] ?? 'wifi',
    locale['amenities']['pool'] ?? 'pool',
  ];
  final List<String> _selectedAmenities = [];
  // final List<String> _allAmenities = ['wifi', 'pool'];
  // final List<String> _selectedAmenities = [];

  // final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedCover;
  final List<XFile> _pickedImages = [];

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    try {
      final data = await _getGovernatesAndCities.getGovernorates();
      if (!mounted) return;
      setState(() {
        governorates = data;
        isLoadingGovs = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoadingGovs = false);
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
      });
    } catch (e) {
      if (mounted) setState(() => isLoadingCities = false);
    }
  }

  // Future<void> _pickCover() async {
  //   final image = await _imagePicker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 85,
  //   );
  //   if (image != null) setState(() => _pickedCover = image);
  // }

  // Future<void> _pickImages() async {
  //   final images = await _imagePicker.pickMultiImage(imageQuality: 85);
  //   if (images.isNotEmpty) setState(() => _pickedImages.addAll(images));
  // }

  void _saveApartment() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedGov == null || selectedCity == null) {
        _showSnackBar(
          locale['location']['errorSelection'] ??
              'Please select governorate and city',
        );
        return;
      }

      if (_pickedCover == null) {
        _showSnackBar(
          locale['imageSection']['errorNoImages'] ??
              'Please add at least one image',
        );

        if (_pickedCover == null) {
          _showSnackBar('Please add a cover image');
          return;
        }

        setState(() => isSaving = true);

        List<String> combinedPaths = [
          _pickedCover!.path,
          ..._pickedImages.map((e) => e.path),
        ];

        Apartment apartment = Apartment(
          title: _titleController.text,
          pricePerNight: double.tryParse(_priceController.text) ?? 0.0,
          imagePath: combinedPaths.first,
          rating: '0',
          ratingCount: 0,
          beds: int.tryParse(_bedsController.text) ?? 0,
          baths: int.tryParse(_bathsController.text) ?? 0,
          areaSqft: double.tryParse(_areaController.text) ?? 0.0,
          description: _descriptionController.text,
          imagesPaths: combinedPaths,
          amenities: _selectedAmenities,
          city: selectedCity,
          governorate: selectedGov,
        );

        Response? response = await AddApartmentService.addApartment(
          context: context,
          apartment: apartment,
          cityId: selectedCity!.id,
        );

        setState(() => isSaving = false);

        if (response != null && response.statusCode == 201) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppBottomNavBar.routeName,
            (route) => false,
          );
        } else {
          _showSnackBar('Failed to add apartment.');
        }
      }
    } else {
      _showSnackBar(
        locale['fields']['requiredError'] ?? 'Please fill all required fields',
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Add Apartment')),
  //     body: Stack(
  //       children: [
  //         SingleChildScrollView(
  //           padding: const EdgeInsets.all(16),
  //           child: Form(
  //             key: _formKey,
  //             child: Column(
  //               children: [
  //                 _sectionHeader("Cover Image (Required)"),
  //                 _coverPickerUI(),
  //                 const SizedBox(height: 20),
  //                 _sectionHeader("Gallery Images"),
  //                 _galleryPickerUI(),
  //                 const SizedBox(height: 16),
  //                 _field(_titleController, 'Title', Icons.home),
  //                 _buildLocationSelectors(),
  //                 _field(
  //                   _priceController,
  //                   'Price per night',
  //                   Icons.attach_money,
  //                   inputType: TextInputType.number,
  //                 ),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: _field(
  //                         _bedsController,
  //                         'Beds',
  //                         Icons.bed,
  //                         inputType: TextInputType.number,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: _field(
  //                         _bathsController,
  //                         'Baths',
  //                         Icons.bathtub,
  //                         inputType: TextInputType.number,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 _field(
  //                   _areaController,
  //                   'Area',
  //                   Icons.square_foot,
  //                   inputType: TextInputType.number,
  //                 ),
  //                 _field(
  //                   _descriptionController,
  //                   'Description',
  //                   Icons.description,
  //                   maxlines: 3,
  //                 ),
  //                 _amenitiesSection(),
  //                 const SizedBox(height: 24),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 50,
  //                   child: ElevatedButton(
  //                     onPressed: isSaving ? null : _saveApartment,
  //                     child: isSaving
  //                         ? const CircularProgressIndicator(color: Colors.white)
  //                         : const Text('Save Apartment'),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         if (isSaving) Container(color: Colors.black26),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildLocationSelectors() {
  //   return Column(
  //     children: [
  //       _buildFilterRow(
  //         label: 'المحافظة',
  //         value: selectedGov?.name,
  //         child: isLoadingGovs
  //             ? const CircularProgressIndicator(strokeWidth: 2)
  //             : DropdownButton<Governorate>(
  //                 isExpanded: true,
  //                 hint: const Text('اختر محافظة'),
  //                 value: selectedGov,
  //                 items: governorates
  //                     .map(
  //                       (gov) =>
  //                           DropdownMenuItem(value: gov, child: Text(gov.name)),
  //                     )
  //                     .toList(),
  //                 onChanged: _onGovernorateChanged,
  //               ),
  //       ),
  //       _buildFilterRow(
  //         label: 'المدينة',
  //         value: selectedCity?.name,
  //         child: isLoadingCities
  //             ? const LinearProgressIndicator()
  //             : DropdownButton<City>(
  //                 isExpanded: true,
  //                 hint: Text(
  //                   selectedGov == null ? 'اختر محافظة أولاً' : 'اختر مدينة',
  //                 ),
  //                 value: selectedCity,
  //                 items: cities
  //                     .map(
  //                       (city) => DropdownMenuItem(
  //                         value: city,
  //                         child: Text(city.name),
  //                       ),
  //                     )
  //                     .toList(),
  //                 onChanged: (val) => setState(() => selectedCity = val),
  //               ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _coverPickerUI() {
  //   return GestureDetector(
  //     onTap: _pickCover,
  //     child: Container(
  //       height: 150,
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.blue.shade100),
  //         color: Colors.blue.withOpacity(0.05),
  //       ),
  //       child: _pickedCover != null
  //           ? ClipRRect(
  //               borderRadius: BorderRadius.circular(12),
  //               child: Image.file(File(_pickedCover!.path), fit: BoxFit.cover),
  //             )
  //           : const Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
  //                 Text(
  //                   "Select Cover Image",
  //                   style: TextStyle(color: Colors.blue),
  //                 ),
  //               ],
  //             ),
  //     ),
  //   );
  // }

  // Widget _galleryPickerUI() {
  //   return SizedBox(
  //     height: 100,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       children: [
  //         ..._pickedImages.asMap().entries.map(
  //           (e) => _galleryTile(
  //             Image.file(File(e.value.path), fit: BoxFit.cover),
  //             () => setState(() => _pickedImages.removeAt(e.key)),
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: _pickImages,
  //           child: Container(
  //             width: 100,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.grey.shade300),
  //             ),
  //             child: const Icon(
  //               Icons.add_photo_alternate_outlined,
  //               color: Colors.grey,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _galleryTile(Widget image, VoidCallback onRemove) {
  //   return Stack(
  //     children: [
  //       Container(
  //         width: 100,
  //         height: 100,
  //         margin: const EdgeInsets.only(right: 8),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(12),
  //           child: image,
  //         ),
  //       ),
  //       Positioned(
  //         right: 12,
  //         top: 4,
  //         child: GestureDetector(
  //           onTap: onRemove,
  //           child: const CircleAvatar(
  //             radius: 10,
  //             backgroundColor: Colors.red,
  //             child: Icon(Icons.close, size: 12, color: Colors.white),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _sectionHeader(String title) => Align(
  //   alignment: Alignment.centerLeft,
  //   child: Padding(
  //     padding: const EdgeInsets.only(bottom: 8.0),
  //     child: Text(
  //       title,
  //       style: const TextStyle(
  //         fontSize: 14,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.grey,
  //       ),
  //     ),
  //   ),
  // );

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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                value ?? '-',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
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
        Text(
          locale['amenities']['title'] ?? 'Amenities',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._allAmenities.map(
          (amenity) => CheckboxListTile(
            value: _selectedAmenities.contains(amenity),
            title: Text(amenity),
            onChanged: (val) => setState(
              () => val!
                  ? _selectedAmenities.add(amenity)
                  : _selectedAmenities.remove(amenity),
            ),
          ),
        ),
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
      appBar: AppBar(title: Text(locale['appBarTitle'] ?? 'Add Apartment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _field(
                _titleController,
                locale['fields']['title'] ?? 'Title',
                Icons.home,
              ),
              _buildFilterRow(
                label: locale['location']['governorate'] ?? 'Governorate',
                value: selectedGov?.name,
                child: isLoadingGovs
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : DropdownButton<Governorate>(
                        isExpanded: true,
                        hint: Text(
                          locale['location']['selectGov'] ??
                              'Select Governorate',
                        ),
                        value: selectedGov,
                        items: governorates.map((gov) {
                          return DropdownMenuItem(
                            value: gov,
                            child: Text(gov.localized(context)),
                          );
                        }).toList(),
                        onChanged: _onGovernorateChanged,
                      ),
              ),
              _buildFilterRow(
                label: locale['location']['city'] ?? 'City',
                value: selectedCity?.localized(context),
                child: isLoadingCities
                    ? const LinearProgressIndicator()
                    : DropdownButton<City>(
                        isExpanded: true,
                        hint: Text(
                          selectedGov == null
                              ? locale['location']['selectGovFirst'] ??
                                    'Select governorate first'
                              : locale['location']['selectCity'] ??
                                    'Select City',
                        ),
                        value: selectedCity,
                        items: cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city.localized(context)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedCity = val),
                      ),
              ),
              _field(
                _priceController,
                locale['fields']['price'] ?? 'Price per night',
                Icons.attach_money,
                inputType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _bedsController,
                      locale['fields']['beds'] ?? 'Beds',
                      Icons.bed,
                      inputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _bathsController,
                      locale['fields']['baths'] ?? 'Baths',
                      Icons.bathtub,
                      inputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _field(
                _areaController,
                locale['fields']['area'] ?? 'Area',
                Icons.square_foot,
                inputType: TextInputType.number,
              ),
              _field(
                _descriptionController,
                locale['fields']['description'] ?? 'Description',
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
                  child: Text(locale['buttons']['save'] ?? 'Save Apartment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // IconData _getAmenityIcon(String amenity) {
  //   if (amenity.toLowerCase() == 'wifi') return Icons.wifi;
  //   if (amenity.toLowerCase() == 'pool') return Icons.pool;
  //   return Icons.check_circle_outline;
  // }
}
