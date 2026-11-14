import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { sw, en }

class LocaleNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return AppLanguage.sw; // Kiswahili default as per requirements
  }

  void setLanguage(AppLanguage language) {
    state = language;
  }

  void toggleLanguage() {
    state = state == AppLanguage.sw ? AppLanguage.en : AppLanguage.sw;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLanguage>(
  () => LocaleNotifier(),
);

class AppStrings {
  static String get(AppLanguage lang, String key) {
    final values = _translations[key];
    if (values == null) return key;
    return values[lang] ?? values[AppLanguage.sw] ?? key;
  }

  static const Map<String, Map<AppLanguage, String>> _translations = {
    // Navigation
    'nav_explore': {AppLanguage.sw: 'Gundua', AppLanguage.en: 'Explore'},
    'nav_bookings': {AppLanguage.sw: 'Bookings', AppLanguage.en: 'Bookings'},
    'nav_add': {AppLanguage.sw: 'Weka Kifaa', AppLanguage.en: 'Add Item'},
    'nav_profile': {AppLanguage.sw: 'Wasifu', AppLanguage.en: 'Profile'},

    // Explore & Home
    'search_hint': {
      AppLanguage.sw: 'Tafuta vifaa vya ujenzi, sherehe, ukumbi...',
      AppLanguage.en: 'Search construction tools, party items, venues...',
    },
    'cat_all': {AppLanguage.sw: 'Zote', AppLanguage.en: 'All'},
    'cat_party': {
      AppLanguage.sw: '🎉 Sherehe',
      AppLanguage.en: '🎉 Events & Party',
    },
    'cat_construction': {
      AppLanguage.sw: '🏗️ Ujenzi',
      AppLanguage.en: '🏗️ Construction',
    },
    'cat_venue': {AppLanguage.sw: '🏛️ Ukumbi', AppLanguage.en: '🏛️ Venues'},
    'available_items': {
      AppLanguage.sw: 'Vifaa Vinavyopatikana',
      AppLanguage.en: 'Available Items',
    },
    'per_day': {AppLanguage.sw: '/ siku', AppLanguage.en: '/ day'},

    // Profile & Menu
    'my_profile': {
      AppLanguage.sw: 'Wasifu Wangu',
      AppLanguage.en: 'My Profile',
    },
    'role_renter': {
      AppLanguage.sw: 'Mkodishaji (Renter)',
      AppLanguage.en: 'Renter',
    },
    'role_owner': {
      AppLanguage.sw: 'Mwenye Vifaa (Owner)',
      AppLanguage.en: 'Equipment Owner',
    },
    'edit_profile': {
      AppLanguage.sw: 'Hariri Taarifa',
      AppLanguage.en: 'Edit Profile',
    },
    'booking_history': {
      AppLanguage.sw: 'Historia ya Bookings',
      AppLanguage.en: 'Booking History',
    },
    'booking_history_sub': {
      AppLanguage.sw: 'Tazama bookings zilizopita na maoni',
      AppLanguage.en: 'View past bookings and reviews',
    },
    'owner_dashboard': {
      AppLanguage.sw: 'Vifaa Vyangu & Mapato',
      AppLanguage.en: 'My Items & Earnings',
    },
    'owner_dashboard_sub': {
      AppLanguage.sw: 'Tazama vifaa ulivyoweka, maombi na mapato',
      AppLanguage.en: 'Manage your listings, bookings and revenue',
    },
    'payment_history': {
      AppLanguage.sw: 'Historia ya Malipo',
      AppLanguage.en: 'Payment History',
    },
    'payment_history_sub': {
      AppLanguage.sw: 'Tazama stakabadhi na malipo yote',
      AppLanguage.en: 'View all payment receipts and transactions',
    },
    'notifications': {
      AppLanguage.sw: 'Arifa & Taarifa',
      AppLanguage.en: 'Notifications',
    },
    'language': {
      AppLanguage.sw: 'Lugha / Language',
      AppLanguage.en: 'Language / Lugha',
    },
    'help_support': {
      AppLanguage.sw: 'Msaada & Mawasiliano',
      AppLanguage.en: 'Help & Support',
    },
    'privacy_policy': {
      AppLanguage.sw: 'Sera ya Faragha & Masharti',
      AppLanguage.en: 'Privacy Policy & Terms',
    },
    'about_app': {
      AppLanguage.sw: 'Kuhusu Kodisha MVP',
      AppLanguage.en: 'About Kodisha MVP',
    },
    'logout': {
      AppLanguage.sw: 'Toka Kwenye Akaunti (Logout)',
      AppLanguage.en: 'Log Out',
    },

    // Owner Dashboard
    'total_earnings': {
      AppLanguage.sw: 'Jumla ya Mapato',
      AppLanguage.en: 'Total Earnings',
    },
    'active_listings': {
      AppLanguage.sw: 'Vifaa Vilivyopo',
      AppLanguage.en: 'Active Listings',
    },
    'total_bookings': {
      AppLanguage.sw: 'Jumla ya Bookings',
      AppLanguage.en: 'Total Bookings',
    },
    'avg_rating': {
      AppLanguage.sw: 'Wastani wa Nyota',
      AppLanguage.en: 'Average Rating',
    },
    'my_listings': {
      AppLanguage.sw: 'Orodha ya Vifaa Vyangu',
      AppLanguage.en: 'My Equipment List',
    },
    'recent_payments': {
      AppLanguage.sw: 'Malipo Yaliyopokelewa Hivi Karibuni',
      AppLanguage.en: 'Recently Received Payments',
    },
    'available': {AppLanguage.sw: 'Inapatikana', AppLanguage.en: 'Available'},
    'unavailable': {
      AppLanguage.sw: 'Haipatikani',
      AppLanguage.en: 'Unavailable',
    },

    // Bookings
    'my_bookings': {
      AppLanguage.sw: 'Bookings Zangu',
      AppLanguage.en: 'My Bookings',
    },
    'status_pending': {AppLanguage.sw: 'Inasubiri', AppLanguage.en: 'Pending'},
    'status_confirmed': {
      AppLanguage.sw: 'Imethibitishwa',
      AppLanguage.en: 'Confirmed',
    },
    'status_completed': {
      AppLanguage.sw: 'Imekamilika',
      AppLanguage.en: 'Completed',
    },
    'status_cancelled': {
      AppLanguage.sw: 'Imefutwa',
      AppLanguage.en: 'Cancelled',
    },
    'pay_now': {AppLanguage.sw: 'Lipa Sasa', AppLanguage.en: 'Pay Now'},
    'add_review': {
      AppLanguage.sw: 'Toa Review',
      AppLanguage.en: 'Leave Review',
    },
    'cancel': {AppLanguage.sw: 'Ghairi', AppLanguage.en: 'Cancel'},
  };
}
