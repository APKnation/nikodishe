import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../data/models/listing_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/providers/bookings_provider.dart';
import '../../../listings/providers/listings_provider.dart';
import '../../../payments/providers/payments_provider.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);
    final allListings = ref.watch(listingsProvider);
    final allPayments = ref.watch(paymentsProvider);
    final allBookings = ref.watch(bookingsProvider);

    // Filter owner's data (defaulting to user_001 if testing)
    final ownerId = user?.id ?? 'user_001';
    final myListings = allListings.where((l) => l.ownerId == ownerId || l.ownerName == user?.name).toList();
    final ownerPayments = allPayments.where((p) => p.ownerId == ownerId).toList();
    final ownerBookings = allBookings.where((b) => b.ownerId == ownerId).toList();

    final totalEarnings = ownerPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final avgRating = myListings.isNotEmpty
        ? (myListings.map((l) => l.rating).reduce((a, b) => a + b) / myListings.length)
        : 5.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'owner_dashboard')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: AppStrings.get(lang, 'nav_add'),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue & Metrics Overview
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
                    color: AppColors.primary.withOpacity(0.3),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TZS ${_formatPrice(totalEarnings)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricTile(
                        title: AppStrings.get(lang, 'active_listings'),
                        value: '${myListings.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                      _buildMetricTile(
                        title: AppStrings.get(lang, 'total_bookings'),
                        value: '${ownerBookings.length}',
                        icon: Icons.calendar_month_outlined,
                      ),
                      _buildMetricTile(
                        title: AppStrings.get(lang, 'avg_rating'),
                        value: '⭐ ${avgRating.toStringAsFixed(1)}',
                        icon: Icons.star_border,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section: My Equipment List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get(lang, 'my_listings'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${myListings.length} ${lang == AppLanguage.sw ? 'vifaa' : 'items'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (myListings.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        lang == AppLanguage.sw
                            ? 'Hujaweka kifaa chochote bado'
                            : 'You have not listed any equipment yet',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.go('/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(AppStrings.get(lang, 'nav_add')),
                      ),
                    ],
                  ),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
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
                                  SnackBar(
                                    content: Text(
                                      val
                                          ? (lang == AppLanguage.sw ? 'Kifaa kinaonekana kinapatikana' : 'Item marked as available')
                                          : (lang == AppLanguage.sw ? 'Kifaa kimewekwa hakipatikani' : 'Item marked as unavailable'),
                                    ),
                                  ),
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
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.rating.toStringAsFixed(1)} (${item.reviewCount} ${lang == AppLanguage.sw ? 'maoni' : 'reviews'})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    context.push('/listings/${item.id}');
                                  },
                                  icon: const Icon(Icons.visibility_outlined, size: 14),
                                  label: Text(lang == AppLanguage.sw ? 'Tazama' : 'View', style: const TextStyle(fontSize: 12)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  onPressed: () {
                                    ref.read(listingsProvider.notifier).deleteListing(item.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          lang == AppLanguage.sw ? 'Kifaa kimefutwa' : 'Item deleted',
                                        ),
                                      ),
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

            // Section: Recent Payments Received
            Text(
              AppStrings.get(lang, 'recent_payments'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (ownerPayments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    lang == AppLanguage.sw
                        ? 'Bado hujapokea malipo'
                        : 'No payments received yet',
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pay.listingTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kutoka: ${pay.renterName} • ${pay.methodLabel}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Text(
                          '+ TZS ${_formatPrice(pay.amount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: 14,
                          ),
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

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

