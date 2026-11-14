import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/review_model.dart';
import '../../../data/services/api_service.dart';
import '../../listings/providers/listings_provider.dart';

class ReviewsNotifier extends Notifier<List<ReviewModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<ReviewModel> build() => const [];

  Future<void> loadForListing(String listingId) async {
    try {
      final reviews = await _apiService.fetchReviewsByListing(listingId);
      final others = state.where((r) => r.listingId != listingId).toList();
      state = [...reviews, ...others];
    } catch (_) {}
  }

  Future<void> addReview(ReviewModel review) async {
    state = [review, ...state];

    try {
      await _apiService.createReview(
        bookingId: review.bookingId,
        rating: review.rating.toInt(),
        comment: review.comment,
      );
      await loadForListing(review.listingId);
    } catch (_) {
      // If backend is unavailable, local review still shows
    }

    // Update the listing's local average rating
    final listingReviews = state
        .where((r) => r.listingId == review.listingId)
        .toList();
    if (listingReviews.isNotEmpty) {
      final avg =
          listingReviews.map((r) => r.rating).reduce((a, b) => a + b) /
          listingReviews.length;
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

final reviewsProvider = NotifierProvider<ReviewsNotifier, List<ReviewModel>>(
  () => ReviewsNotifier(),
);

final reviewsForListingProvider = Provider.family<List<ReviewModel>, String>((
  ref,
  listingId,
) {
  final all = ref.watch(reviewsProvider);
  return all.where((r) => r.listingId == listingId).toList();
});

final reviewsForOwnerProvider = Provider.family<List<ReviewModel>, String>((
  ref,
  ownerId,
) {
  final all = ref.watch(reviewsProvider);
  return all.where((r) => r.ownerId == ownerId).toList();
});
