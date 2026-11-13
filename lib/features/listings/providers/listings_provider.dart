import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/mock/mock_data.dart';

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
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedLocation:
          clearLocation ? null : (selectedLocation ?? this.selectedLocation),
    );
  }
}

// ---------------------------------------------------------------------------
// SearchNotifier  (StateNotifier so the provider spec uses StateNotifierProvider)
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

  void clearAll() => state = const SearchState();
}

// ---------------------------------------------------------------------------
// ListingsNotifier
// ---------------------------------------------------------------------------
class ListingsNotifier extends Notifier<List<ListingModel>> {
  @override
  List<ListingModel> build() => List<ListingModel>.from(mockListings);

  void addListing(ListingModel listing) {
    state = [...state, listing];
  }

  void updateListing(ListingModel updated) {
    state = [
      for (final l in state)
        if (l.id == updated.id) updated else l,
    ];
  }

  void deleteListing(String id) {
    state = state.where((l) => l.id != id).toList();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final listingsProvider = NotifierProvider<ListingsNotifier, List<ListingModel>>(
  () => ListingsNotifier(),
);

final searchStateProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

final filteredListingsProvider = Provider<List<ListingModel>>((ref) {
  final listings = ref.watch(listingsProvider);
  final search = ref.watch(searchStateProvider);

  return listings.where((listing) {
    // Query filter — matches title, description or location.
    if (search.query.isNotEmpty) {
      final q = search.query.toLowerCase();
      final matches = listing.title.toLowerCase().contains(q) ||
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
      if (!listing.location.toLowerCase().contains(loc)) return false;
    }

    return true;
  }).toList();
});

final listingByIdProvider =
    Provider.family<ListingModel?, String>((ref, id) {
  final listings = ref.watch(listingsProvider);
  try {
    return listings.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
});
