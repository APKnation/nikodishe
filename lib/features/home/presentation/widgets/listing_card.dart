import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../data/models/listing_model.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  Color _getCategoryColor(ListingCategory cat) {
    switch (cat) {
      case ListingCategory.sherehe:
        return const Color(0xFFEC4899);
      case ListingCategory.ujenzi:
        return const Color(0xFFF59E0B);
      case ListingCategory.ukumbi:
        return const Color(0xFF8B5CF6);
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
      subtitle: 'TZS ${_formatPrice(listing.pricePerDay)} / siku • ${listing.location}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(listing.category);
    final hasRealImage = listing.images.isNotEmpty &&
        listing.images.first.trim().isNotEmpty &&
        listing.images.first != 'placeholder.jpg';

    return InkWell(
      onTap: () => context.push('/listings/${listing.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area (Prominent & Eye-Catching)
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: hasRealImage
                      ? AppNetworkImage(
                          imageUrl: listing.images.first,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholderIcon: _getCategoryIcon(listing.category),
                        )
                      : Container(
                          color: catColor.withOpacity(0.15),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(listing.category),
                              size: 52,
                              color: catColor,
                            ),
                          ),
                        ),
                ),

                // Category Tag (Top Left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      listing.categoryLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Rating Badge (Top Right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          listing.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // "View Full Image" Quick Button (Bottom Right of Image)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _openFullscreenImage(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Picha',
                            style: TextStyle(
                              color: Colors.white,
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

            // Content Details Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title (2 Lines allowed so text doesn't truncate awkwardly)
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),

                    // Location
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
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Price & Availability Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'TZS ${_formatPrice(listing.pricePerDay)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              children: const [
                                TextSpan(
                                  text: '\n/ siku',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: listing.isAvailable
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            listing.isAvailable ? 'Ipo' : 'Haitapatikana',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: listing.isAvailable ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
