import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/backend_status_banner.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'explore_tab.dart';

/// Customer home: shared marketplace (all owners' items), bookings, profile.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);

    // Owners use a separate dashboard and management pages
    if (user != null && user.role.name == 'owner') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/owner/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = const [
      ExploreTab(),
      MyBookingsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          const BackendStatusBanner(),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore, color: AppColors.primary),
              label: AppStrings.get(lang, 'nav_explore'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              label: AppStrings.get(lang, 'nav_bookings'),
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
