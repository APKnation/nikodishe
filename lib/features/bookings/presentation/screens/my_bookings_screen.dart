import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../data/models/booking_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../reviews/presentation/widgets/add_review_dialog.dart';
import '../../providers/bookings_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  BookingStatus? _selectedStatus;
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedInitialLoad) {
      _requestedInitialLoad = true;
      // Hakikisha data za mteja aliyeingia zinavutwa
      Future.microtask(() => ref.read(bookingsProvider.notifier).loadFromApi());
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.amber;
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.confirmed:
        return Icons.verified_rounded;
      case BookingStatus.completed:
        return Icons.check_circle_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);
    final allBookings = ref.watch(myBookingsProvider);
    final filteredBookings = _selectedStatus == null
        ? allBookings
        : allBookings.where((b) => b.status == _selectedStatus).toList();

    final pendingCount = allBookings.where((b) => b.status == BookingStatus.pending).length;
    final confirmedCount = allBookings.where((b) => b.status == BookingStatus.confirmed).length;
    final completedCount = allBookings.where((b) => b.status == BookingStatus.completed).length;
    final totalSpent = allBookings
        .where((b) => b.status != BookingStatus.cancelled)
        .fold<double>(0, (sum, b) => sum + b.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'my_bookings')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: AppStrings.get(lang, 'refresh'),
            onPressed: () => ref.read(bookingsProvider.notifier).loadFromApi(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(bookingsProvider.notifier).loadFromApi(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildCustomerHeader(
              context,
              userName: user?.name ?? 'Mteja',
              phone: user?.phone ?? '',
              location: user?.location,
              photoUrl: user?.photoUrl,
              totalBookings: allBookings.length,
              pending: pendingCount,
              confirmed: confirmedCount,
              completed: completedCount,
              totalSpent: totalSpent,
              lang: lang,
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(null, '${AppStrings.get(lang, 'all_items')} (${allBookings.length})'),
                    const SizedBox(width: 8),
                    _buildTab(
                      BookingStatus.pending,
                      '${AppStrings.get(lang, 'status_pending')} ($pendingCount)',
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      BookingStatus.confirmed,
                      '${AppStrings.get(lang, 'status_confirmed')} ($confirmedCount)',
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      BookingStatus.completed,
                      '${AppStrings.get(lang, 'status_completed')} ($completedCount)',
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      BookingStatus.cancelled,
                      AppStrings.get(lang, 'status_cancelled'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (filteredBookings.isEmpty)
              _buildEmptyState(context, lang)
            else
              ...filteredBookings.map(
                (booking) => _buildBookingCard(context, booking, lang),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHeader(
    BuildContext context, {
    required String userName,
    required String phone,
    String? location,
    String? photoUrl,
    required int totalBookings,
    required int pending,
    required int confirmed,
    required int completed,
    required double totalSpent,
    required AppLanguage lang,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.blueSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Container(
                  width: 52,
                  height: 52,
                  color: AppColors.onColor.withOpacity(0.2),
                  child: (photoUrl != null && photoUrl.isNotEmpty)
                      ? AppNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholderIcon: Icons.person,
                        )
                      : const Icon(Icons.person, color: AppColors.onColor, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(lang, 'customer_info'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.onColor, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone.isNotEmpty
                          ? phone
                          : AppStrings.get(lang, 'no_phone'),
                      style: TextStyle(color: AppColors.onColor.withOpacity(0.9), fontSize: 12.5),
                    ),
                    if (location != null && location.trim().isNotEmpty)
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.onColor.withOpacity(0.85), fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.onColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.onColor.withOpacity(0.25)),
                ),
                child: Text(
                  AppStrings.get(lang, 'my_account'),
                  style: TextStyle(color: AppColors.onColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _headerStat(AppStrings.get(lang, 'total'), '$totalBookings'),
              _headerDivider(),
              _headerStat(AppStrings.get(lang, 'status_pending'), '$pending'),
              _headerDivider(),
              _headerStat(
                AppStrings.get(lang, 'status_confirmed'),
                '$confirmed',
              ),
              _headerDivider(),
              _headerStat(
                AppStrings.get(lang, 'status_completed'),
                '$completed',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.onColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.onColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get(lang, 'total_cost_excl'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Text(
                  'TZS ${_formatPrice(totalSpent)}',
                  style: const TextStyle(color: AppColors.onColor, fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: AppColors.onColor, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColors.onColor.withOpacity(0.85), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _headerDivider() => Container(width: 1, height: 26, color: AppColors.onColor.withOpacity(0.25));

  Widget _buildEmptyState(BuildContext context, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 14),
           Text(
            AppStrings.get(lang, 'empty_bookings_title'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
           Text(
            AppStrings.get(lang, 'empty_bookings_sub'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => context.go('/home'),
            child: Text(AppStrings.get(lang, 'browse_items')),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    BookingModel booking,
    AppLanguage lang,
  ) {
    final statusColor = _getStatusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    booking.listingTitle,
                    style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(booking.status), size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(lang, booking.status),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow(
              Icons.confirmation_number_outlined,
              'Booking ID',
              '#${booking.id}',
            ),
            const SizedBox(height: 6),
            _infoRow(
              Icons.person_outline,
              AppStrings.get(lang, 'owner_label'),
              booking.ownerName,
            ),
            const SizedBox(height: 6),
            _infoRow(
              Icons.date_range,
              AppStrings.get(lang, 'date_label'),
              '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}',
            ),
            const SizedBox(height: 6),
            _infoRow(
              Icons.timelapse_outlined,
              AppStrings.get(lang, 'duration_label'),
              '${booking.totalDays} ${AppStrings.get(lang, 'days')}',
            ),

            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppStrings.get(lang, 'total_payment'),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TZS ${_formatPrice(booking.totalPrice)}',
                      style:  TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                _buildAction(context, booking, lang),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ', style:  TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:  TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(
    BuildContext context,
    BookingModel booking,
    AppLanguage lang,
  ) {
    if (booking.status == BookingStatus.pending) {
      return OutlinedButton(
        onPressed: () async {
          await ref.read(bookingsProvider.notifier).updateStatus(booking.id, BookingStatus.cancelled);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.get(lang, 'booking_cancelled_snack'))),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(AppStrings.get(lang, 'cancel')),
      );
    }
    if (booking.status == BookingStatus.confirmed) {
      return ElevatedButton.icon(
        onPressed: () => context.push('/payments/pay?bookingId=${booking.id}'),
        icon: const Icon(Icons.payment, size: 16),
        label: Text(AppStrings.get(lang, 'pay_now')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    if (booking.status == BookingStatus.completed) {
      return OutlinedButton.icon(
        onPressed: () {
          showDialog(context: context, builder: (_) => AddReviewDialog(booking: booking));
        },
        icon: const Icon(Icons.star_rate_rounded, size: 16, color: AppColors.amber),
        label: Text(AppStrings.get(lang, 'add_review')),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side:  BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blueTintSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        AppStrings.get(lang, 'no_action'),
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel(AppLanguage lang, BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppStrings.get(lang, 'status_pending');
      case BookingStatus.confirmed:
        return AppStrings.get(lang, 'status_confirmed');
      case BookingStatus.completed:
        return AppStrings.get(lang, 'status_completed');
      case BookingStatus.cancelled:
        return AppStrings.get(lang, 'status_cancelled');
    }
  }

  Widget _buildTab(BookingStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.onColor : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      showCheckmark: false,
    );
  }
}
