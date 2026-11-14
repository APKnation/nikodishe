import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../data/models/listing_model.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;

  const ListingCard({super.key, required this.listing});

  Color _getCategoryColor(ListingCategory cat) {
    switch (cat) {
      case ListingCategory.sherehe:
        return AppColors.primary;
      case ListingCategory.ujenzi:
        return AppColors.amber;
      case ListingCategory.ukumbi:
        return AppColors.blueSoft;
    }
  }

  IconData _getCategoryIcon(ListingCategory cat) {
    switch (cat) {
      case ListingCategory.sherehe:
        return Icons.celebration;
      case ListingCategory.ujenzi:
        return Icons.construction;
      case ListingCategory.ukumbi:
        return Icons.meeting_room;
    }
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _openFullscreenImage(BuildContext context) {
    FullscreenImageViewer.show(
      context,
      images: listing.images,
      title: listing.title,
      subtitle:
          'TZS ${_formatPrice(listing.pricePerDay)} / siku • ${listing.location}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(listing.category);
    final hasRealImage =
        listing.images.isNotEmpty &&
        listing.images.first.trim().isNotEmpty &&
        listing.images.first != 'placeholder.jpg';

    return InkWell(
      onTap: () => context.push('/listings/${listing.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Picha: urefu na upana sawa kwenye kadi zote
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasRealImage
                      ? AppNetworkImage(
                          imageUrl: listing.images.first,
                          fit: BoxFit.cover,
                          placeholderIcon: _getCategoryIcon(listing.category),
                        )
                      : Container(
                          color: catColor.withOpacity(0.12),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(listing.category),
                              size: 48,
                              color: catColor,
                            ),
                          ),
                        ),

                  // Category tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blueDark.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        listing.categoryLabel,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Rating
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueDark.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            listing.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick view
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _openFullscreenImage(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueDark.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen,
                              color: AppColors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Picha',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Maelezo: kadi inajirekebisha kulingana na content (hakuna nafasi tupu)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${listing.categoryLabel} • ${listing.typeLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blueTintSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TZS ${_formatPrice(listing.pricePerDay)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                'kwa siku',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: listing.isAvailable
                                ? AppColors.primaryLight
                                : AppColors.amberTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.isAvailable ? 'Inapatikana' : 'Haipo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: listing.isAvailable
                                  ? AppColors.primary
                                  : AppColors.amberDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
