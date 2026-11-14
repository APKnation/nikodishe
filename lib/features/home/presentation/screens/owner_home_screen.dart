import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backend_status_banner.dart';
import '../../../listings/presentation/screens/add_listing_screen.dart';
import '../../../profile/presentation/screens/owner_dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class OwnerHomeScreen extends ConsumerStatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  ConsumerState<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends ConsumerState<OwnerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [
      OwnerDashboardScreen(),
      AddListingScreen(),
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
              label: 'Dashibodi',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
              label: 'Weka Kifaa',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Wasifu',
            ),
          ],
        ),
      ),
    );
  }
}
