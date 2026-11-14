import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/payment_model.dart';
import '../../../data/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentsNotifier extends Notifier<List<PaymentModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<PaymentModel> build() {
    ref.listen(currentUserProvider, (_, __) {
      Future.microtask(() => loadFromApi());
    });
    Future.microtask(() => loadFromApi());
    return const [];
  }

  Future<void> loadFromApi() async {
    try {
      final remote = await _apiService.fetchMyPayments();
      state = remote;
    } catch (_) {
      // Backend offline or unauthenticated
    }
  }

  Future<bool> processPayment(PaymentModel payment) async {
    state = [payment, ...state];
    try {
      final remote = await _apiService.processPayment(
        bookingId: payment.bookingId,
        amount: payment.amount,
        method: payment.method,
        type: payment.type,
        phoneNumber: payment.phoneNumber,
      );
      state = [remote, ...state.where((p) => p.id != payment.id)];
      return true;
    } catch (_) {
      // keep pending/optimistic state removed on failure? mark failed
      state = [
        for (final p in state)
          if (p.id == payment.id)
            p.copyWith(status: PaymentStatus.failed)
          else
            p,
      ];
      return false;
    }
  }
}

final paymentsProvider = NotifierProvider<PaymentsNotifier, List<PaymentModel>>(
  () => PaymentsNotifier(),
);

/// Payments made by current renter
final renterPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final payments = ref.watch(paymentsProvider);
  if (user == null) return payments;
  if (user.role.name == 'renter') {
    return payments
        .where((p) => p.renterId == user.id || p.renterId.isEmpty)
        .toList();
  }
  return payments;
});

/// Payments received by current owner (FR20)
final ownerPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final payments = ref.watch(paymentsProvider);
  if (user == null) return const [];
  return payments
      .where((p) => p.ownerId == user.id || p.ownerId.isEmpty)
      .toList();
});
