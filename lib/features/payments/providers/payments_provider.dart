import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentsNotifier extends Notifier<List<PaymentModel>> {
  @override
  List<PaymentModel> build() {
    return List.from(mockPayments);
  }

  Future<bool> processPayment(PaymentModel payment) async {
    // Add pending payment first
    state = [payment, ...state];

    // Simulate network & mobile money USSD push delay
    await Future.delayed(const Duration(seconds: 2));

    // Update status to completed
    state = state.map((p) {
      if (p.id == payment.id) {
        return p.copyWith(status: PaymentStatus.completed);
      }
      return p;
    }).toList();

    return true;
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

