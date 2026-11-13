import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/offline_storage_service.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../listings/providers/listings_provider.dart';

// ---------------------------------------------------------------------------
// BookingsNotifier
// ---------------------------------------------------------------------------
class BookingsNotifier extends Notifier<List<BookingModel>> {
  @override
  List<BookingModel> build() => List<BookingModel>.from(mockBookings);

  void createBooking(BookingModel booking) {
    state = [...state, booking];
    // NFR14: Guarantee persistence even if app closes immediately
    OfflineStorageService.instance.saveBookings(state);
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
/// Params: record type `({String listingId, DateTime start, DateTime end})`.
final bookingPriceProvider = Provider.family<double,
    ({String listingId, DateTime start, DateTime end})>((ref, params) {
  final listing = ref.watch(listingByIdProvider(params.listingId));
  if (listing == null) return 0.0;
  final days = params.end.difference(params.start).inDays;
  if (days <= 0) return 0.0;
  return listing.pricePerDay * days;
});
