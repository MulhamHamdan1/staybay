import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staybay/cubits/locale/locale_cubit.dart';
import 'package:staybay/models/apartment_model.dart';
import 'package:staybay/models/city_model.dart';
import 'package:staybay/models/governorate_model.dart';
import 'package:staybay/services/add_favorite_service.dart';
import 'package:staybay/services/remove_favorite_service.dart';
import '../app_theme.dart';
import '../widgets/details_image_carousel.dart';
import '../widgets/custom_primary_button.dart';
import '../widgets/amenities_responsive_grid.dart';
import 'booking_details_screen.dart';
// import '../widgets/rating_dialog.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  static const String routeName = 'details';

  final Apartment apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  Map<String, dynamic> get locale =>
      context.read<LocaleCubit>().state.localizedStrings['apartmentDetails'];

  late bool _isFavorite;

  @override
  initState() {
    _isFavorite = widget.apartment.isFavorite;
    super.initState();
  }

  Widget _buildFeatureIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: AppSizes.paddingSmall / 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(apartment: widget.apartment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apartmentDetails = widget.apartment;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 350.0,
              pinned: true,
              floating: false,
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    widget.apartment.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                      widget.apartment.isFavorite = _isFavorite;
                      if (_isFavorite) {
                        AddFavoriteService.addFavorite(
                          context,
                          int.parse(widget.apartment.id!),
                        );
                      } else {
                        RemoveFavoriteService.removeFavorite(
                          context,
                          int.parse(widget.apartment.id!),
                        );
                      }
                    });
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: DetailsImageCarousel(
                  imagesPaths: apartmentDetails.imagesPaths,
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apartmentDetails.title,
                style: AppStyles.titleStyle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSizes.paddingSmall / 2),
                      Text(
                        '${apartmentDetails.governorate?.localized(context)},${apartmentDetails.city?.localized(context)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: apartmentDetails.pricePerNight.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            fontSize: 22,
                          ),
                        ),
                        TextSpan(
                          text: locale['perNight'] ?? ' / night',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSizes.paddingLarge * 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureIcon(
                    context,
                    icon: Icons.king_bed,
                    label: locale['bedrooms'] ?? 'Bedrooms',
                    value: '${apartmentDetails.beds}',
                  ),
                  _buildFeatureIcon(
                    context,
                    icon: Icons.bathtub,
                    label: locale['bathrooms'] ?? 'Bathrooms',
                    value: '${apartmentDetails.baths}',
                  ),
                  _buildFeatureIcon(
                    context,
                    icon: Icons.square_foot,
                    label: locale['area'] ?? 'Area',
                    value: '${apartmentDetails.areaSqft} ',
                  ),
                ],
              ),
              const Divider(height: AppSizes.paddingLarge * 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_2_rounded,
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: Text(
                          '${locale['owner'] ?? 'Owner: '} ${apartmentDetails.ownerName}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  // done from backend get rating and rating count
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < int.parse(apartmentDetails.rating)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        const SizedBox(width: AppSizes.paddingSmall),
                        Text(
                          '(${apartmentDetails.ratingCount} ${locale['reviews'] ?? 'Reviews'})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: AppSizes.paddingLarge * 2),

              Text(
                locale['amenities'] ?? 'Amenities & Services',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              AmenitiesResponsiveGrid(amenities: apartmentDetails.amenities),
              const Divider(height: AppSizes.paddingLarge * 2),

              Text(
                locale['description'] ?? 'Description',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                apartmentDetails.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.paddingExtraLarge),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: CustomPrimaryButton(
          text: locale['bookNow'] ?? 'Book Now',
          onPressed: () => _navigateToBooking(context),
        ),
      ),
    );
  }
}
