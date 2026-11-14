import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/graphql_client.dart';

// ---------------------------------------------------------------------------
// AuthState
// ---------------------------------------------------------------------------
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isOtpSent;

  /// Message returned by the backend when an OTP is requested.
  final String? otpMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
    this.otpMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isOtpSent,
    String? otpMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearOtpMessage = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otpMessage: clearOtpMessage ? null : (otpMessage ?? this.otpMessage),
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

  /// Send OTP using identifier (email or phone). Returns resolved phone on success.
  /// The human-readable confirmation comes from the backend, never hardcoded.
  Future<String?> sendOtp(String identifier) async {
    state = state.copyWith(isLoading: true, clearError: true, clearOtpMessage: true);
    try {
      final result = await _apiService.sendOtp(identifier);
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        otpMessage: result['message'] as String?,
      );
      return result['phone'] as String?;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Verify OTP using resolved phone/identifier
  Future<void> verifyOtp(String phone, String otp, UserRole role) async {
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
      // OTP verified but no account yet (customer phone flow)
      state = state.copyWith(isLoading: false, isOtpSent: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Log out the current user
  void logout() {
    GraphQLClient().setAuthToken(null);
    state = const AuthState();
  }

  /// Register a new customer (public). Owners are added by super admin only.
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
        role: UserRole.renter,
        location: location,
        whatsapp: whatsapp,
        instagram: instagram,
        facebook: facebook,
        tiktok: tiktok,
        nidaNumber: nidaNumber,
      );
      state = state.copyWith(isLoading: false, user: user, isOtpSent: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Login for equipment owners using phone + password (owner added by super admin)
  Future<void> loginOwner({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _apiService.loginWithPassword(
        phone: phone,
        password: password,
      );
      state = state.copyWith(isLoading: false, user: user, isOtpSent: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update the current user's profile via backend when possible.
  Future<void> updateProfile({
    String? name,
    String? location,
    String? photoUrl,
  }) async {
    final current = state.user;
    if (current == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _apiService.updateProfile(
        name: name,
        location: location,
      );
      state = state.copyWith(
        isLoading: false,
        user: updated.copyWith(
          photoUrl: photoUrl ?? updated.photoUrl ?? current.photoUrl,
        ),
      );
    } catch (e) {
      // Keep local update if backend fails (e.g. photo-only local path)
      state = state.copyWith(
        isLoading: false,
        user: current.copyWith(
          name: name ?? current.name,
          location: location ?? current.location,
          photoUrl: photoUrl ?? current.photoUrl,
        ),
      );
    }
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
