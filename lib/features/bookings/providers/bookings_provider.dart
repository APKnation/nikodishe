import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/offline_storage_service.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../listings/providers/listings_provider.dart';

// ---------------------------------------------------------------------------
// BookingsNotifier
// ---------------------------------------------------------------------------
class BookingsNotifier extends Notifier<List<BookingModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<BookingModel> build() {
    final initialList = List<BookingModel>.from(mockBookings);
    Future.microtask(() => loadFromApi());
    return initialList;
  }

  Future<void> loadFromApi() async {
    try {
      final remote = await _apiService.fetchMyBookings();
      if (remote.isNotEmpty) {
        state = remote;
        OfflineStorageService.instance.saveBookings(remote);
      }
    } catch (_) {
      // Backend offline
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    state = [...state, booking];
    OfflineStorageService.instance.saveBookings(state);

    try {
      final remoteBooking = await _apiService.createBooking(
        listingId: booking.listingId,
        startDate: booking.startDate,
        endDate: booking.endDate,
      );
      state = [
        remoteBooking,
        ...state.where((b) => b.id != booking.id),
      ];
      OfflineStorageService.instance.saveBookings(state);
    } catch (_) {
      // Retain optimistic local booking
    }
  }

  void updateStatus(String bookingId, BookingStatus status) {
    state = [
      for (final b in state)
        if (b.id == bookingId) b.copyWith(status: status) else b,
    ];
    OfflineStorageService.instance.saveBookings(state);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final bookingsProvider =
    NotifierProvider<BookingsNotifier, List<BookingModel>>(
  () => BookingsNotifier(),
);

/// All bookings where the current user is the renter.
final myBookingsProvider = Provider<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref
      .watch(bookingsProvider)
      .where((b) => b.renterId == user.id)
      .toList();
});

/// All bookings where the current user is the owner (incoming requests).
final ownerBookingsProvider = Provider<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref
      .watch(bookingsProvider)
      .where((b) => b.ownerId == user.id)
      .toList();
});

/// Helper to calculate total price for a prospective booking.
final bookingPriceProvider = Provider.family<double,
    ({String listingId, DateTime start, DateTime end})>((ref, params) {
  final listing = ref.watch(listingByIdProvider(params.listingId));
  if (listing == null) return 0;
  final days = params.end.difference(params.start).inDays;
  final effectiveDays = days <= 0 ? 1 : days;
  return listing.pricePerDay * effectiveDays;
});
