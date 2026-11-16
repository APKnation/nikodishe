import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/listing_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/services/api_service.dart';

// ---------------------------------------------------------------------------
// SearchState
// ---------------------------------------------------------------------------
class SearchState {
  final String query;
  final ListingCategory? selectedCategory;
  final ListingType? selectedType;
  final String? selectedLocation;

  const SearchState({
    this.query = '',
    this.selectedCategory,
    this.selectedType,
    this.selectedLocation,
  });

  SearchState copyWith({
    String? query,
    ListingCategory? selectedCategory,
    ListingType? selectedType,
    String? selectedLocation,
    bool clearCategory = false,
    bool clearType = false,
    bool clearLocation = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedLocation: clearLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
    );
  }
}

// ---------------------------------------------------------------------------
// SearchNotifier
// ---------------------------------------------------------------------------
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) => state = state.copyWith(query: query);

  void setCategory(ListingCategory? category) => state = state.copyWith(
    selectedCategory: category,
    clearCategory: category == null,
  );

  void setType(ListingType? type) =>
      state = state.copyWith(selectedType: type, clearType: type == null);

  void setLocation(String? location) => state = state.copyWith(
    selectedLocation: location,
    clearLocation: location == null,
  );

  void reset() => state = const SearchState();
}

// ---------------------------------------------------------------------------
// ListingsNotifier (Connected with GraphQL API)
// ---------------------------------------------------------------------------
class ListingsNotifier extends Notifier<List<ListingModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<ListingModel> build() {
    // 1. Initial fast local state (instant startup)
    final initialList = List<ListingModel>.from(mockListings);

    // 2. Fetch live listings asynchronously from GraphQL backend
    Future.microtask(() => loadFromApi());

    return initialList;
  }

  /// Load listings from Django GraphQL API
  Future<void> loadFromApi() async {
    try {
      final remoteListings = await _apiService.fetchListings();
      if (remoteListings.isNotEmpty) {
        // Merge or replace
        state = remoteListings;
      }
    } catch (_) {
      // Server offline / fallback to existing listings
    }
  }

  /// Add new listing and push to backend
  Future<void> addListing(ListingModel listing) async {
    state = [listing, ...state];
    try {
      final created = await _apiService.createListing(listing);
      debugPrint(
        'KIFAA KIMEWEKWA BACKEND: ID=${created.id}, Jina=${created.title}',
      );
      state = [created, ...state.where((l) => l.id != listing.id)];
    } catch (e) {
      debugPrint('HITILAFU YA KUTUMA KIFAA KWENYE BACKEND: $e');
    }
  }

  Future<void> updateListing(ListingModel updated) async {
    state = [
      for (final l in state)
        if (l.id == updated.id) updated else l,
    ];
    // Try to sync availability/edits for server-side listings (numeric IDs)
    if (!updated.id.startsWith('user_') && !updated.id.startsWith('listing_')) {
      try {
        final remote = await _apiService.updateListing(
          id: updated.id,
          title: updated.title,
          description: updated.description,
          category: updated.category,
          listingType: updated.type,
          pricePerDay: updated.pricePerDay,
          location: updated.location,
          isAvailable: updated.isAvailable,
        );
        state = [
          for (final l in state)
            if (l.id == updated.id) remote else l,
        ];
      } catch (e) {
        debugPrint('HITILAFU YA KUSASISHA KIFAA: $e');
      }
    }
  }

  Future<void> deleteListing(String id) async {
    state = state.where((l) => l.id != id).toList();
    try {
      await _apiService.deleteListing(id);
    } catch (e) {
      debugPrint('HITILAFU YA KUFUTA KIFAA: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final listingsProvider = NotifierProvider<ListingsNotifier, List<ListingModel>>(
  () => ListingsNotifier(),
);

final searchStateProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

/// Vifaa alivyovipenda mtumiaji kwenye kikao hiki.
final favoriteListingsProvider = StateProvider<Set<String>>((ref) => <String>{});

final filteredListingsProvider = Provider<List<ListingModel>>((ref) {
  final listings = ref.watch(listingsProvider);
  final search = ref.watch(searchStateProvider);

  return listings.where((listing) {
    // Query filter — matches title, description or location.
    if (search.query.isNotEmpty) {
      final q = search.query.toLowerCase();
      final matches =
          listing.title.toLowerCase().contains(q) ||
          listing.description.toLowerCase().contains(q) ||
          listing.location.toLowerCase().contains(q);
      if (!matches) return false;
    }

    // Category filter.
    if (search.selectedCategory != null &&
        listing.category != search.selectedCategory) {
      return false;
    }

    // Type filter.
    if (search.selectedType != null &&
        listing.type != search.selectedType &&
        listing.type != ListingType.zote) {
      return false;
    }

    // Location filter.
    if (search.selectedLocation != null &&
        search.selectedLocation!.isNotEmpty) {
      final loc = search.selectedLocation!.toLowerCase();
      if (!listing.location.toLowerCase().contains(loc)) {
        return false;
      }
    }

    return true;
  }).toList();
});

final listingByIdProvider = Provider.family<ListingModel?, String>((ref, id) {
  final listings = ref.watch(listingsProvider);
  for (final listing in listings) {
    if (listing.id == id) return listing;
  }
  // Fallback kwa data ya mfano (bookings za mock zina listingId za mock).
  for (final listing in mockListings) {
    if (listing.id == id) return listing;
  }
  return null;
});

/// Hupata kifaa kutoka kwenye state, mock data, au backend.
/// Hii inahakikisha "Angalia Kifaa" inafanya kazi hata kama
/// orodha ya vifaa bado haijapakiwa kwenye kifaa.
final listingDetailProvider = FutureProvider.autoDispose
    .family<ListingModel?, String>((ref, id) async {
      if (id.trim().isEmpty) return null;

      final local = ref.watch(listingByIdProvider(id));
      if (local != null) return local;

      try {
        return await ApiService().fetchListingById(id);
      } catch (_) {
        return null;
      }
    });
