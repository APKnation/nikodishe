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

  Widget _guestGate(BuildContext context, {required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.blueTintSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 14),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.45)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push('/auth/phone', extra: {'redirectTo': '/home'}),
                  child: const Text('Ingia / Jisajili'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

    final isGuest = user == null;

    final screens = [
      const ExploreTab(),
      isGuest
          ? _guestGate(
              context,
              title: 'Ingia ili kuona bookings zako',
              subtitle: 'Unaweza kutazama vifaa vyote bila akaunti. Ili kuweka au kufuatilia booking, tafadhali ingia au jisajili.',
            )
          : const MyBookingsScreen(),
      isGuest
          ? _guestGate(
              context,
              title: 'Ingia ili kutumia wasifu wako',
              subtitle: 'Fungua akaunti au ingia ili kusimamia taarifa zako, bookings na malipo kwa urahisi.',
            )
          : const ProfileScreen(),
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
