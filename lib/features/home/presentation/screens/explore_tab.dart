import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/ai_bounce_icon.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../data/models/listing_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../notifications/providers/notifications_provider.dart';
import '../../../listings/providers/listings_provider.dart';
import '../widgets/listing_card.dart';

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final searchState = ref.watch(searchStateProvider);
    final listings = ref.watch(filteredListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/support/chat'),
        tooltip: AppStrings.get(lang, 'ai_tooltip'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AiBounceIcon(size: 44, bounceHeight: 4),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(height: 30, radius: 8),
            const SizedBox(width: 8),
            const Text(
              'Kodisha',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.get(lang, 'language'),
            icon: const Icon(Icons.translate_rounded),
            onPressed: () =>
                ref.read(localeProvider.notifier).toggleLanguage(),
          ),
          IconButton(
            tooltip: AppStrings.get(lang, 'settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(unreadNotificationsCountProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined),
                    onPressed: () {
                      final user = ref.read(currentUserProvider);
                      if (user == null) {
                        context.push('/auth/phone', extra: {'redirectTo': '/notifications'});
                        return;
                      }
                      context.push('/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: AppColors.onColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [          // Search & Filter Header
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(searchStateProvider.notifier).setQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.get(lang, 'search_hint'),
                    hintStyle:  TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon:  Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(searchStateProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: AppStrings.get(lang, 'cat_all'),
                        isSelected: searchState.selectedCategory == null,
                        onSelected: () {
                          ref
                              .read(searchStateProvider.notifier)
                              .setCategory(null);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: AppStrings.get(lang, 'cat_party'),
                        isSelected:
                            searchState.selectedCategory ==
                            ListingCategory.sherehe,
                        onSelected: () {
                          ref
                              .read(searchStateProvider.notifier)
                              .setCategory(
                                searchState.selectedCategory ==
                                        ListingCategory.sherehe
                                    ? null
                                    : ListingCategory.sherehe,
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: AppStrings.get(lang, 'cat_construction'),
                        isSelected:
                            searchState.selectedCategory ==
                            ListingCategory.ujenzi,
                        onSelected: () {
                          ref
                              .read(searchStateProvider.notifier)
                              .setCategory(
                                searchState.selectedCategory ==
                                        ListingCategory.ujenzi
                                    ? null
                                    : ListingCategory.ujenzi,
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: AppStrings.get(lang, 'cat_venue'),
                        isSelected:
                            searchState.selectedCategory ==
                            ListingCategory.ukumbi,
                        onSelected: () {
                          ref
                              .read(searchStateProvider.notifier)
                              .setCategory(
                                searchState.selectedCategory ==
                                        ListingCategory.ukumbi
                                    ? null
                                    : ListingCategory.ukumbi,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total Results Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.get(lang, 'available_items')} (${listings.length})',
                  style:  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Listings Grid / Empty state
          Expanded(
            child: listings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                           Text(
                            AppStrings.get(lang, 'no_items_title'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                           Text(
                            AppStrings.get(lang, 'no_items_sub'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 0; i < listings.length; i += 2) ...[
                                ListingCard(listing: listings[i]),
                                const SizedBox(height: 14),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 1; i < listings.length; i += 2) ...[
                                ListingCard(listing: listings[i]),
                                const SizedBox(height: 14),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.onColor : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
