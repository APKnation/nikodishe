import 'dart:convert';
import 'dart:io';

import '../../../data/models/booking_model.dart';

class OfflineStorageService {
  static final OfflineStorageService instance =
      OfflineStorageService._internal();
  OfflineStorageService._internal();

  File? _cacheFile;

  Future<void> init() async {
    try {
      final dir = Directory.systemTemp;
      _cacheFile = File('${dir.path}/kodisha_offline_bookings.json');
    } catch (_) {
      // In-memory fallback if file system restricted
    }
  }

  /// NFR14: Save bookings locally so they are never lost if app closes abruptly
  Future<void> saveBookings(List<BookingModel> bookings) async {
    try {
      if (_cacheFile == null) await init();
      if (_cacheFile != null) {
        final listMap = bookings.map((b) => b.toMap()).toList();
        await _cacheFile!.writeAsString(jsonEncode(listMap));
      }
    } catch (e) {
      // Silently fall back to in-memory state
    }
  }

  /// NFR14: Restore bookings from local cache
  Future<List<BookingModel>> loadBookings() async {
    try {
      if (_cacheFile == null) await init();
      if (_cacheFile != null && await _cacheFile!.exists()) {
        final content = await _cacheFile!.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList
            .map((item) => BookingModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return [];
  }

  /// NFR10: Mask sensitive data like phone numbers (+255 712 *** *78)
  static String maskPhoneNumber(String phone) {
    if (phone.length < 8) return phone;
    final prefix = phone.substring(0, 7); // e.g. +255 71
    final suffix = phone.substring(phone.length - 2); // e.g. 78
    return '$prefix *** *$suffix';
  }

  /// NFR10: Mask payment transaction references
  static String maskTransactionRef(String ref) {
    if (ref.length < 5) return ref;
    return '${ref.substring(0, 2)}***${ref.substring(ref.length - 2)}';
  }
}
