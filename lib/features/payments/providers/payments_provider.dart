import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentsNotifier extends Notifier<List<PaymentModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<PaymentModel> build() {
    return List.from(mockPayments);
  }

  Future<bool> processPayment(PaymentModel payment) async {
    // Add pending payment first
    state = [payment, ...state];

    try {
      final remote = await _apiService.processPayment(
        bookingId: payment.bookingId,
        amount: payment.amount,
        method: payment.method,
        type: payment.type,
        phoneNumber: payment.phoneNumber,
      );

      state = [
        remote,
        ...state.where((p) => p.id != payment.id),
      ];
      return true;
    } catch (_) {
      // Simulate fallback completion if server is offline
      await Future.delayed(const Duration(milliseconds: 1200));
      state = state.map((p) {
        if (p.id == payment.id) {
          return p.copyWith(status: PaymentStatus.completed);
        }
        return p;
      }).toList();
      return true;
    }
  }
}

final paymentsProvider =
    NotifierProvider<PaymentsNotifier, List<PaymentModel>>(() => PaymentsNotifier());

/// Payments made by current renter
final renterPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final payments = ref.watch(paymentsProvider);
  if (user == null) return payments;
  return payments.where((p) => p.renterId == user.id || p.renterName == user.name).toList();
});

/// Payments received by current owner (FR20)
final ownerPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final payments = ref.watch(paymentsProvider);
  if (user == null) return payments;
  return payments.where((p) => p.ownerId == user.id).toList();
});
