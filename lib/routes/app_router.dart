import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/user_model.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/bookings/presentation/screens/booking_history_screen.dart';
import '../features/bookings/presentation/screens/booking_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/listings/presentation/screens/listing_detail_screen.dart';
import '../features/listings/presentation/screens/owner_contact_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/payments/presentation/screens/payment_history_screen.dart';
import '../features/payments/presentation/screens/payment_screen.dart';
import '../features/home/presentation/screens/owner_home_screen.dart';
import '../features/profile/presentation/screens/owner_dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashWrapper(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) {
          final extraRole = state.extra as UserRole? ?? UserRole.renter;
          return RegisterScreen(initialRole: extraRole);
        },
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '+255700000000';
          final role = extra?['role'] as UserRole? ?? UserRole.renter;
          return OtpScreen(phone: phone, role: role);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/owner/home',
        builder: (context, state) => const OwnerHomeScreen(),
      ),
      GoRoute(
        path: '/listings/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ListingDetailScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '/listings/:id/book',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '/listings/:id/contact',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OwnerContactScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '/payments/pay',
        builder: (context, state) {
          final bookingId =
              state.uri.queryParameters['bookingId'] ?? 'booking_001';
          return PaymentScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/payments/history',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/bookings/history',
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/owner/dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
    ],
  );
}

class _SplashWrapper extends StatefulWidget {
  const _SplashWrapper();

  @override
  State<_SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<_SplashWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.go('/auth/phone');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
