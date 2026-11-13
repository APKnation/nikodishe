import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/services/api_service.dart';

// ---------------------------------------------------------------------------
// AuthState
// ---------------------------------------------------------------------------
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isOtpSent;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isOtpSent,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }
}

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------
class AuthNotifier extends Notifier<AuthState> {
  final ApiService _apiService = ApiService();

  @override
  AuthState build() => const AuthState();

  /// Send OTP using GraphQL API (with fallback simulation if backend is offline)
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiService.sendOtp(phone);
      state = state.copyWith(isLoading: false, isOtpSent: true);
    } catch (_) {
      // Graceful offline fallback
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(isLoading: false, isOtpSent: true);
    }
  }

  /// Verify OTP using GraphQL API
  Future<void> verifyOtp(
    String phone,
    String otp,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _apiService.verifyOtp(phone, otp);
      if (result['user'] != null) {
        state = state.copyWith(
          isLoading: false,
          user: result['user'] as UserModel,
          isOtpSent: false,
        );
        return;
      }
    } catch (_) {
      // Ikiwa seva bado haijawashwa, tumia test code '1234' au '123456'
    }

    // Fallback verification
    if (otp != '1234' && otp != '123456') {
      state = state.copyWith(
        isLoading: false,
        error: 'Msimbo wa OTP si sahihi (Tumia 123456).',
      );
      return;
    }

    UserModel? found;
    try {
      found = mockUsers.firstWhere((u) => u.phone == phone);
    } catch (_) {
      found = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Mtumiaji Mpya',
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );
    }

    state = state.copyWith(isLoading: false, user: found, isOtpSent: false);
  }

  /// Log out the current user
  void logout() {
    state = const AuthState();
  }

  /// Register a new user as Customer (Renter) or Equipment Owner
  Future<void> registerUser({
    required String name,
    required String phone,
    required UserRole role,
    required String location,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? tiktok,
    String? nidaNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _apiService.registerUser(
        phone: phone,
        name: name,
        role: role,
        location: location,
        whatsapp: whatsapp,
        instagram: instagram,
        facebook: facebook,
        tiktok: tiktok,
        nidaNumber: nidaNumber,
      );
      state = state.copyWith(isLoading: false, user: user, isOtpSent: true);
    } catch (_) {
      // Fallback
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        role: role,
        location: location,
        whatsapp: whatsapp ?? phone,
        instagram: instagram,
        facebook: facebook,
        tiktok: tiktok,
        createdAt: DateTime.now(),
      );
      mockUsers.add(newUser);
      state = state.copyWith(isLoading: false, user: newUser, isOtpSent: true);
    }
  }

  /// Switch user role between Renter and Owner
  Future<void> switchRole(UserRole newRole) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(role: newRole);
    state = state.copyWith(user: updated);
  }

  /// Update the current user's display name, location, or photo.
  Future<void> updateProfile({String? name, String? location, String? photoUrl}) async {
    final current = state.user;
    if (current == null) return;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    final updated = current.copyWith(
      name: name ?? current.name,
      location: location ?? current.location,
      photoUrl: photoUrl ?? current.photoUrl,
    );
    state = state.copyWith(isLoading: false, user: updated);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).user,
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);
