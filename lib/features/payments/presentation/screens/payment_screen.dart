import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/providers/bookings_provider.dart';
import '../../../notifications/providers/notifications_provider.dart';
import '../../providers/payments_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const PaymentScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.mpesa;
  PaymentType _selectedType = PaymentType.full;
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _phoneController.text = user?.phone ?? '+255712345678';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return AppColors.primary; // Vodacom Red
      case PaymentMethod.airtelMoney:
        return AppColors.amberDark; // Airtel Red
      case PaymentMethod.tigoPesa:
        return AppColors.blueDark; // Tigo Blue
      case PaymentMethod.haloPesa:
        return AppColors.amber; // Halotel Orange
    }
  }

  Future<void> _handlePayment(BookingModel booking, double amountToPay) async {
    setState(() => _isProcessing = true);

    final user = ref.read(currentUserProvider);
    final payment = PaymentModel(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: booking.id,
      listingTitle: booking.listingTitle,
      renterId: user?.id ?? booking.renterId,
      renterName: user?.name ?? booking.renterName,
      ownerId: booking.ownerId,
      amount: amountToPay,
      method: _selectedMethod,
      type: _selectedType,
      status: PaymentStatus.pending,
      transactionRef:
          'TZ${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      phoneNumber: _phoneController.text.trim(),
      createdAt: DateTime.now(),
    );

    // Process payment with delay
    await ref.read(paymentsProvider.notifier).processPayment(payment);

    // Send push notification for payment (FR23)
    ref
        .read(notificationsProvider.notifier)
        .addNotification(
          title: 'Malipo Yamepokelewa! 💰',
          body:
              'Malipo ya TZS ${_formatPrice(amountToPay)} kupitia ${payment.methodLabel} (Ref: ${payment.referenceCode}) yamekamilika.',
          type: NotificationType.paymentReceived,
          userId: booking.ownerId,
          relatedId: payment.id,
        );

    // Update booking status if full payment
    if (_selectedType == PaymentType.full) {
      ref
          .read(bookingsProvider.notifier)
          .updateStatus(booking.id, BookingStatus.confirmed);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('Malipo Yamekamilika!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Malipo ya TZS ${_formatPrice(amountToPay)} yamefanikiwa kupitia ${payment.methodLabel}.',
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nambari ya Kumbukumbu:',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      payment.referenceCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/payments/history');
              },
              child: const Text('Angalia Risiti'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingsProvider);
    final booking = allBookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => allBookings.first,
    );

    final depositAmount = booking.totalPrice * 0.4; // 40% deposit
    final amountToPay = _selectedType == PaymentType.deposit
        ? depositAmount
        : booking.totalPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Fanya Malipo'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.listingTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jumla ya Booking: TZS ${_formatPrice(booking.totalPrice)} (${booking.totalDays} siku)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Type (Deposit vs Full) - FR18
            const Text(
              'Aina ya Malipo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedType = PaymentType.deposit),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedType == PaymentType.deposit
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == PaymentType.deposit
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedType == PaymentType.deposit
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 18,
                                color: _selectedType == PaymentType.deposit
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Amana (Deposit 40%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'TZS ${_formatPrice(depositAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedType = PaymentType.full),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedType == PaymentType.full
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == PaymentType.full
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedType == PaymentType.full
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 18,
                                color: _selectedType == PaymentType.full
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Malipo Kamili',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'TZS ${_formatPrice(booking.totalPrice)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mobile Money Providers Selection
            const Text(
              'Chagua Mtandao wa Malipo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildMethodTile(
              method: PaymentMethod.mpesa,
              title: 'M-Pesa (Vodacom)',
              subtitle: 'Lipa kwa simu au namba ya Lipa',
              icon: Icons.phone_android,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _buildMethodTile(
              method: PaymentMethod.tigoPesa,
              title: 'Tigo Pesa / Mixx by Yas',
              subtitle: 'Malipo ya haraka na salama',
              icon: Icons.account_balance_wallet,
              color: AppColors.blueDark,
            ),
            const SizedBox(height: 10),
            _buildMethodTile(
              method: PaymentMethod.airtelMoney,
              title: 'Airtel Money',
              subtitle: 'Malipo ya mtandao wa Airtel',
              icon: Icons.phonelink_ring,
              color: AppColors.amberDark,
            ),

            const SizedBox(height: 20),

            // Phone Number Input
            const Text(
              'Namba ya Simu ya Kufanya Malipo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                prefixIcon: const Icon(Icons.dialpad, color: AppColors.primary),
                hintText: '+255 7XX XXX XXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _handlePayment(booking, amountToPay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Tafadhali kamilisha kwenye simu yako...'),
                        ],
                      )
                    : Text(
                        'Lipa TZS ${_formatPrice(amountToPay)} Sasa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
