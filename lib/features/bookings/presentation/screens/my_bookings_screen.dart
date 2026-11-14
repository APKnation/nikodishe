import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
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
        title: const Text('Bookings Zangu'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Onyesha upya',
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
                    _buildTab(null, 'Zote (${allBookings.length})'),
                    const SizedBox(width: 8),
                    _buildTab(BookingStatus.pending, 'Inasubiri ($pendingCount)'),
                    const SizedBox(width: 8),
                    _buildTab(BookingStatus.confirmed, 'Imethibitishwa ($confirmedCount)'),
                    const SizedBox(width: 8),
                    _buildTab(BookingStatus.completed, 'Imekamilika ($completedCount)'),
                    const SizedBox(width: 8),
                    _buildTab(BookingStatus.cancelled, 'Imefutwa'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (filteredBookings.isEmpty)
              _buildEmptyState(context)
            else
              ...filteredBookings.map((booking) => _buildBookingCard(context, booking)),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
                  color: AppColors.white.withOpacity(0.2),
                  child: (photoUrl != null && photoUrl.isNotEmpty)
                      ? AppNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholderIcon: Icons.person,
                        )
                      : const Icon(Icons.person, color: AppColors.white, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Taarifa za Mteja',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone.isNotEmpty ? phone : 'Namba haipo',
                      style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 12.5),
                    ),
                    if (location != null && location.trim().isNotEmpty)
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.white.withOpacity(0.85), fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.white.withOpacity(0.25)),
                ),
                child: const Text(
                  'Akaunti yangu',
                  style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _headerStat('Jumla', '$totalBookings'),
              _headerDivider(),
              _headerStat('Inasubiri', '$pending'),
              _headerDivider(),
              _headerStat('Imethibit.', '$confirmed'),
              _headerDivider(),
              _headerStat('Imekamilika', '$completed'),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Jumla ya gharama (bila zilizofutwa)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Text(
                  'TZS ${_formatPrice(totalSpent)}',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
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
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColors.white.withOpacity(0.85), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _headerDivider() => Container(width: 1, height: 26, color: AppColors.white.withOpacity(0.25));

  Widget _buildEmptyState(BuildContext context) {
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
          const Text(
            'Hakuna historia ya booking hapa',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ukichagua kifaa na kukodi, taarifa na historia yako itaonekana hapa.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => context.go('/home'),
            child: const Text('Tazama Vifaa'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                        booking.statusLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow(Icons.confirmation_number_outlined, 'Booking ID', '#${booking.id}'),
            const SizedBox(height: 6),
            _infoRow(Icons.person_outline, 'Mmiliki', booking.ownerName),
            const SizedBox(height: 6),
            _infoRow(Icons.date_range, 'Tarehe', '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}'),
            const SizedBox(height: 6),
            _infoRow(Icons.timelapse_outlined, 'Muda', '${booking.totalDays} siku'),

            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jumla ya malipo', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      'TZS ${_formatPrice(booking.totalPrice)}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                _buildAction(context, booking),
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
        Text('$label: ', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context, BookingModel booking) {
    if (booking.status == BookingStatus.pending) {
      return OutlinedButton(
        onPressed: () async {
          await ref.read(bookingsProvider.notifier).updateStatus(booking.id, BookingStatus.cancelled);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking imefutwa.')));
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Ghairi'),
      );
    }
    if (booking.status == BookingStatus.confirmed) {
      return ElevatedButton.icon(
        onPressed: () => context.push('/payments/pay?bookingId=${booking.id}'),
        icon: const Icon(Icons.payment, size: 16),
        label: const Text('Lipa Sasa'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
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
        label: const Text('Toa Review'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
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
      child: const Text('Hakuna hatua', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
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
        color: isSelected ? AppColors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      showCheckmark: false,
    );
  }
}
