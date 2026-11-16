import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { sw, en }

class LocaleNotifier extends Notifier<AppLanguage> {
  static const String _storageKey = 'kodisha_language';

  @override
  AppLanguage build() {
    _restore();
    return AppLanguage.sw; // Kiswahili default as per requirements
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved == 'en') state = AppLanguage.en;
      if (saved == 'sw') state = AppLanguage.sw;
    } catch (_) {
      // Tumia default ya Kiswahili
    }
  }

  Future<void> _persist(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, language == AppLanguage.en ? 'en' : 'sw');
    } catch (_) {
      // State ya kikao inatosha
    }
  }

  void setLanguage(AppLanguage language) {
    state = language;
    _persist(language);
  }

  void toggleLanguage() {
    setLanguage(state == AppLanguage.sw ? AppLanguage.en : AppLanguage.sw);
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
    'days': {AppLanguage.sw: 'siku', AppLanguage.en: 'days'},
    'ai_tooltip': {AppLanguage.sw: 'Uliza AI', AppLanguage.en: 'Ask AI'},
    'no_items_title': {
      AppLanguage.sw: 'Hakuna kifaa kilichopatikana',
      AppLanguage.en: 'No items found',
    },
    'no_items_sub': {
      AppLanguage.sw:
          'Jaribu kutafuta kwa jina lingine au kubadilisha category.',
      AppLanguage.en: 'Try a different name or change the category.',
    },

    // Settings
    'settings': {AppLanguage.sw: 'Mipangilio', AppLanguage.en: 'Settings'},
    'settings_sub': {
      AppLanguage.sw: 'Lugha, muonekano na mapendeleo',
      AppLanguage.en: 'Language, appearance and preferences',
    },
    'language_section': {
      AppLanguage.sw: 'Lugha ya App',
      AppLanguage.en: 'App Language',
    },
    'language_desc': {
      AppLanguage.sw: 'Chagua lugha unayotaka kutumia kwenye app nzima.',
      AppLanguage.en: 'Choose the language used across the whole app.',
    },
    'appearance': {
      AppLanguage.sw: 'Muonekano',
      AppLanguage.en: 'Appearance',
    },
    'appearance_desc': {
      AppLanguage.sw: 'Chagua mode nzuri kwa macho yako.',
      AppLanguage.en: 'Choose the look that suits your eyes.',
    },
    'light_mode': {AppLanguage.sw: 'White Mode', AppLanguage.en: 'Light Mode'},
    'dark_mode': {AppLanguage.sw: 'Dark Mode', AppLanguage.en: 'Dark Mode'},
    'light_mode_sub': {
      AppLanguage.sw: 'Angavu na safi — bora kwa mchana',
      AppLanguage.en: 'Bright and clean — best for daytime',
    },
    'dark_mode_sub': {
      AppLanguage.sw: 'Ora ya macho — bora kwa usiku',
      AppLanguage.en: 'Easy on the eyes — best at night',
    },
    'language_swahili': {
      AppLanguage.sw: 'Kiswahili',
      AppLanguage.en: 'Swahili',
    },
    'language_english': {
      AppLanguage.sw: 'Kiingereza',
      AppLanguage.en: 'English',
    },

    // Landing / Get Started
    'landing_headline': {
      AppLanguage.sw: 'Kodisha vitu kwa urahisi',
      AppLanguage.en: 'Rent anything, easily',
    },
    'landing_sub': {
      AppLanguage.sw:
          'Pata vifaa vya sherehe, ujenzi na ukumbi kwa haraka,\nkwa bei nafuu na kwa usalama — mahali popote Tanzania.',
      AppLanguage.en:
          'Find event, construction and venue equipment fast,\nat fair prices and safely — anywhere in Tanzania.',
    },
    'get_started': {
      AppLanguage.sw: 'Anza Sasa',
      AppLanguage.en: 'Get Started',
    },
    'have_account': {
      AppLanguage.sw: 'Nina akaunti? Ingia',
      AppLanguage.en: 'Already have an account? Sign in',
    },
    'landing_footer': {
      AppLanguage.sw:
          'Vifaa vilivyothibitishwa • Malipo salama • Msaada wa AI',
      AppLanguage.en:
          'Verified equipment • Secure payments • AI support',
    },

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
    'refresh': {AppLanguage.sw: 'Onyesha upya', AppLanguage.en: 'Refresh'},
    'all_items': {AppLanguage.sw: 'Zote', AppLanguage.en: 'All'},
    'customer_info': {
      AppLanguage.sw: 'Taarifa za Mteja',
      AppLanguage.en: 'Customer Details',
    },
    'my_account': {
      AppLanguage.sw: 'Akaunti yangu',
      AppLanguage.en: 'My account',
    },
    'total': {AppLanguage.sw: 'Jumla', AppLanguage.en: 'Total'},
    'no_phone': {AppLanguage.sw: 'Namba haipo', AppLanguage.en: 'No phone number'},
    'total_cost_excl': {
      AppLanguage.sw: 'Jumla ya gharama (bila zilizofutwa)',
      AppLanguage.en: 'Total cost (excluding cancelled)',
    },
    'empty_bookings_title': {
      AppLanguage.sw: 'Hakuna historia ya booking hapa',
      AppLanguage.en: 'No booking history yet',
    },
    'empty_bookings_sub': {
      AppLanguage.sw:
          'Ukichagua kifaa na kukodi, taarifa na historia yako itaonekana hapa.',
      AppLanguage.en:
          'When you choose an item and book it, your details and history will appear here.',
    },
    'browse_items': {
      AppLanguage.sw: 'Tazama Vifaa',
      AppLanguage.en: 'Browse Items',
    },
    'owner_label': {AppLanguage.sw: 'Mmiliki', AppLanguage.en: 'Owner'},
    'date_label': {AppLanguage.sw: 'Tarehe', AppLanguage.en: 'Date'},
    'duration_label': {AppLanguage.sw: 'Muda', AppLanguage.en: 'Duration'},
    'total_payment': {
      AppLanguage.sw: 'Jumla ya malipo',
      AppLanguage.en: 'Total payment',
    },
    'booking_cancelled_snack': {
      AppLanguage.sw: 'Booking imefutwa.',
      AppLanguage.en: 'Booking cancelled.',
    },
    'no_action': {AppLanguage.sw: 'Hakuna hatua', AppLanguage.en: 'No action'},
  };
}
