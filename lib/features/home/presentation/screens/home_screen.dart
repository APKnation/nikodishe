import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../providers/app_providers.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../listings/presentation/screens/add_listing_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'explore_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final lang = ref.watch(localeProvider);

    final screens = const [
      ExploreTab(),
      MyBookingsScreen(),
      AddListingScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) {
            ref.read(bottomNavIndexProvider.notifier).state = idx;
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore, color: AppColors.primary),
              label: AppStrings.get(lang, 'nav_explore'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
              label: AppStrings.get(lang, 'nav_bookings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: const Icon(Icons.add_circle, color: AppColors.primary),
              label: AppStrings.get(lang, 'nav_add'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: AppStrings.get(lang, 'nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}


