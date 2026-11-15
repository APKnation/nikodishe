import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../data/models/booking_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/providers/bookings_provider.dart';
import '../../../listings/providers/listings_provider.dart';
import '../../../payments/providers/payments_provider.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loaded) return;
      _loaded = true;
      ref.read(bookingsProvider.notifier).loadFromApi();
      ref.read(listingsProvider.notifier).loadFromApi();
    });
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);
    final allListings = ref.watch(listingsProvider);
    final allPayments = ref.watch(paymentsProvider);
    final allBookings = ref.watch(bookingsProvider);

    final ownerId = user?.id ?? '';
    final myListings = allListings.where((l) => l.ownerId == ownerId).toList();
    final ownerPayments = allPayments.where((p) => p.ownerId == ownerId).toList();
    final ownerBookings = allBookings.where((b) => b.ownerId == ownerId).toList();

    final totalEarnings = ownerPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final avgRating = myListings.isNotEmpty
        ? (myListings.map((l) => l.rating).reduce((a, b) => a + b) / myListings.length)
        : 0.0;

    if (user == null || user.role.name != 'owner') {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashibodi ya Mwenye Kifaa')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Ukurasa huu ni wa wenye vifaa waliothibitishwa na Super Admin pekee.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'owner_dashboard')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blueTintSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Karibu, ${user.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hii ni dashibodi yako binafsi ya kusimamia vifaa vyako. Vifaa vyako vinaonekana kwenye dashibodi ya pamoja ya wateja.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get(lang, 'total_earnings'),
                    style: TextStyle(color: AppColors.white.withOpacity(0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TZS ${_formatPrice(totalEarnings)}',
                    style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricTile(title: AppStrings.get(lang, 'active_listings'), value: '${myListings.length}', icon: Icons.inventory_2_outlined),
                      _buildMetricTile(title: AppStrings.get(lang, 'total_bookings'), value: '${ownerBookings.length}', icon: Icons.calendar_month_outlined),
                      _buildMetricTile(title: AppStrings.get(lang, 'avg_rating'), value: avgRating > 0 ? '⭐ ${avgRating.toStringAsFixed(1)}' : '—', icon: Icons.star_border),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/owner/insights'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang == AppLanguage.sw
                                ? 'Uchambuzi wa AI'
                                : 'AI Insights',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lang == AppLanguage.sw
                                ? 'Chambua bookings, mapato na vifaa vyako kwa AI'
                                : 'Analyze your bookings, revenue and listings with AI',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get(lang, 'my_listings'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text('${myListings.length} ${lang == AppLanguage.sw ? 'vifaa' : 'items'}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),

            if (myListings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      lang == AppLanguage.sw ? 'Hujaweka kifaa chochote bado' : 'You have not listed any equipment yet',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Bonyeza "Weka Kifaa" kwenye menyu ya chini ili kuongeza kifaa chako cha kwanza.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myListings.length,
                itemBuilder: (context, index) {
                  final item = myListings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.handyman, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TZS ${_formatPrice(item.pricePerDay)} / siku • ${item.categoryLabel}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: item.isAvailable,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                final updated = item.copyWith(isAvailable: val);
                                ref.read(listingsProvider.notifier).updateListing(updated);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(val ? 'Kifaa kinaonekana kinapatikana' : 'Kifaa kimewekwa hakipatikani')),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text('${item.rating.toStringAsFixed(1)} (${item.reviewCount})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => context.push('/listings/${item.id}'),
                                  icon: const Icon(Icons.visibility_outlined, size: 14),
                                  label: Text(lang == AppLanguage.sw ? 'Tazama' : 'View', style: const TextStyle(fontSize: 12)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  onPressed: () {
                                    ref.read(listingsProvider.notifier).deleteListing(item.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(lang == AppLanguage.sw ? 'Kifaa kimefutwa' : 'Item deleted')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maombi ya Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  '${ownerBookings.length} ${lang == AppLanguage.sw ? 'maombi' : 'requests'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ownerBookings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Bado hakuna maombi ya booking kwa vifaa vyako.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ownerBookings.length,
                itemBuilder: (context, index) {
                  final b = ownerBookings[index];
                  final statusColor = b.status == BookingStatus.pending
                      ? AppColors.amber
                      : b.status == BookingStatus.confirmed
                          ? AppColors.primary
                          : b.status == BookingStatus.completed
                              ? AppColors.success
                              : AppColors.error;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.listingTitle,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Mteja: ${b.renterName}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tarehe: ${b.startDate.day}/${b.startDate.month}/${b.startDate.year} - ${b.endDate.day}/${b.endDate.month}/${b.endDate.year} (${b.totalDays} siku)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: statusColor.withOpacity(0.35)),
                              ),
                              child: Text(
                                b.statusLabel,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TZS ${_formatPrice(b.totalPrice)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            Row(
                              children: [
                                if (b.status == BookingStatus.pending)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await ref.read(bookingsProvider.notifier).updateStatus(b.id, BookingStatus.confirmed);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Booking imethibitishwa.')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Thibitisha'),
                                  ),
                                if (b.status == BookingStatus.pending) const SizedBox(width: 8),
                                if (b.status == BookingStatus.pending)
                                  OutlinedButton(
                                    onPressed: () async {
                                      await ref.read(bookingsProvider.notifier).updateStatus(b.id, BookingStatus.cancelled);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Booking imekataliwa.')),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Kataa'),
                                  ),
                                if (b.status == BookingStatus.confirmed)
                                  OutlinedButton(
                                    onPressed: () async {
                                      await ref.read(bookingsProvider.notifier).updateStatus(b.id, BookingStatus.completed);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Booking imemarkiwa imekamilika.')),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Kamilisha'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
            Text(AppStrings.get(lang, 'recent_payments'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (ownerPayments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Center(
                  child: Text(
                    lang == AppLanguage.sw ? 'Bado hujapokea malipo' : 'No payments received yet',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ownerPayments.length,
                itemBuilder: (context, index) {
                  final pay = ownerPayments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pay.listingTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Kutoka: ${pay.renterName} • ${pay.methodLabel}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        Text(
                          '+ TZS ${_formatPrice(pay.amount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({required String title, required String value, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.85), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(title, style: TextStyle(color: AppColors.white.withOpacity(0.85), fontSize: 10)),
      ],
    );
  }
}
