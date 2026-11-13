import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/review_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../listings/providers/listings_provider.dart';

class ReviewsNotifier extends Notifier<List<ReviewModel>> {
  @override
  List<ReviewModel> build() {
    return List.from(mockReviews);
  }

  void addReview(ReviewModel review) {
    state = [review, ...state];

    // Optionally update the listing's rating
    final listingReviews = state.where((r) => r.listingId == review.listingId).toList();
    if (listingReviews.isNotEmpty) {
      final avg = listingReviews.map((r) => r.rating).reduce((a, b) => a + b) / listingReviews.length;
      final currentListings = ref.read(listingsProvider);
      final index = currentListings.indexWhere((l) => l.id == review.listingId);
      if (index != -1) {
        final updatedListing = currentListings[index].copyWith(
          rating: double.parse(avg.toStringAsFixed(1)),
          reviewCount: listingReviews.length,
        );
        ref.read(listingsProvider.notifier).updateListing(updatedListing);
      }
    }
  }
}

final reviewsProvider =
    NotifierProvider<ReviewsNotifier, List<ReviewModel>>(() => ReviewsNotifier());

final reviewsForListingProvider =
    Provider.family<List<ReviewModel>, String>((ref, listingId) {
  final all = ref.watch(reviewsProvider);
  return all.where((r) => r.listingId == listingId).toList();
});

final reviewsForOwnerProvider =
    Provider.family<List<ReviewModel>, String>((ref, ownerId) {
  final all = ref.watch(reviewsProvider);
  return all.where((r) => r.ownerId == ownerId).toList();
});

