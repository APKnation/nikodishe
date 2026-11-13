import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/mock/mock_data.dart';

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
  @override
  AuthState build() => const AuthState();

  /// Simulate sending OTP to [phone]. Sets isOtpSent = true after 1 s delay.
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false, isOtpSent: true);
  }

  /// Verify OTP. Mock: "1234" always succeeds.
  /// On success, tries to find an existing mock user with [phone]; otherwise
  /// creates a new one.
  Future<void> verifyOtp(
    String phone,
    String otp,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(seconds: 1));

    if (otp != '1234') {
      state = state.copyWith(
        isLoading: false,
        error: 'OTP si sahihi. Jaribu tena.',
      );
      return;
    }

    // Look for an existing mock user with this phone number.
    UserModel? found;
    try {
      found = mockUsers.firstWhere((u) => u.phone == phone);
    } catch (_) {
      // No existing user — create a new one.
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

  /// Log out the current user.
  void logout() {
    state = const AuthState();
  }

  /// Update the current user's display name and optional location.
  Future<void> updateProfile(String name, String? location) async {
    final current = state.user;
    if (current == null) return;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final updated = current.copyWith(name: name, location: location);
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
