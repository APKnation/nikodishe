import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/offline_storage_service.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/user_model.dart';
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
    ref.listen<UserModel?>(currentUserProvider, (_, __) {
      Future.microtask(() => loadFromApi());
    });
    Future.microtask(() => loadFromApi());
    return const [];
  }

  Future<void> loadFromApi() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = const [];
        return;
      }
      final remote = user.role.name == 'owner'
          ? await _apiService.fetchOwnerBookings()
          : await _apiService.fetchMyBookings();
      state = remote;
      OfflineStorageService.instance.saveBookings(remote);
    } catch (_) {
      // Backend offline or unauthenticated
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
      state = [remoteBooking, ...state.where((b) => b.id != booking.id)];
      OfflineStorageService.instance.saveBookings(state);
    } catch (_) {
      // Retain optimistic local booking
    }
  }

  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    state = [
      for (final b in state)
        if (b.id == bookingId) b.copyWith(status: status) else b,
    ];
    OfflineStorageService.instance.saveBookings(state);
    try {
      final updated = await _apiService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      state = [
        for (final b in state)
          if (b.id == bookingId) updated else b,
      ];
      OfflineStorageService.instance.saveBookings(state);
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final bookingsProvider = NotifierProvider<BookingsNotifier, List<BookingModel>>(
  () => BookingsNotifier(),
);

/// All bookings where the current user is the renter.
final myBookingsProvider = Provider<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final bookings = ref.watch(bookingsProvider);
  if (user == null) return bookings;
  if (user.role.name == 'owner') return bookings;
  return bookings
      .where((b) => b.renterId == user.id || b.renterId.isEmpty)
      .toList();
});

/// All bookings where the current user is the owner (incoming requests).
final ownerBookingsProvider = Provider<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final bookings = ref.watch(bookingsProvider);
  if (user == null) return const [];
  return bookings
      .where((b) => b.ownerId == user.id || b.ownerId.isEmpty)
      .toList();
});

/// Helper to calculate total price for a prospective booking.
final bookingPriceProvider =
    Provider.family<double, ({String listingId, DateTime start, DateTime end})>(
      (ref, params) {
        final listing = ref.watch(listingByIdProvider(params.listingId));
        if (listing == null) return 0;
        final days = params.end.difference(params.start).inDays;
        final effectiveDays = days <= 0 ? 1 : days;
        return listing.pricePerDay * effectiveDays;
      },
    );
