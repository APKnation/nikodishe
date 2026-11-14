import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_wave.dart';
import '../../../../core/widgets/wave_header.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final UserRole role;
  final String? redirectTo;
  final String? identifier;

  /// Confirmation message returned by the backend when the OTP was requested.
  final String? sentMessage;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    this.redirectTo,
    this.identifier,
    this.sentMessage,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;
  String? _message;

  @override
  void initState() {
    super.initState();
    _message = widget.sentMessage;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else if (mounted) {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tafadhali ingiza nambari zote 6 za OTP')),
      );
      return;
    }
    await ref.read(authProvider.notifier).verifyOtp(widget.phone, _otp, widget.role);
    final authState = ref.read(authProvider);
    if (!mounted) return;
    if (authState.user != null) {
      if (authState.user!.role == UserRole.owner) {
        context.go('/owner/home');
      } else {
        context.go(widget.redirectTo ?? '/home');
      }
    } else if (authState.error == null) {
      // OTP verified but account not registered yet (customer flow)
      context.go('/auth/register', extra: {
        'role': UserRole.renter,
        'phone': widget.phone,
        'redirectTo': widget.redirectTo,
      });
    }
  }

  Future<void> _handleResend() async {
    if (_secondsLeft > 0) return;
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    final message = ref.read(authProvider).otpMessage;
    if (!mounted) return;
    if (message != null && message.isNotEmpty) {
      setState(() => _message = message);
    }
    _startCountdown();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isComplete = _otp.length == 6;
    final size = MediaQuery.sizeOf(context);
    final bool compact = size.height < 700 || size.width < 360;
    final double headerHeight =
        (size.height * (compact ? 0.29 : 0.31)).clamp(170.0, 268.0).toDouble();
    final double waveHeight = (size.height * 0.10).clamp(62.0, 100.0).toDouble();
    final double hPad = size.width < 360 ? 20 : 28;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          WaveHeader(
            height: headerHeight,
            colors: const [AppColors.blue, AppColors.blue],
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white.withOpacity(0.18),
                        foregroundColor: AppColors.white,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    Text(
                      'Thibitisha OTP',
                      style: TextStyle(
                        fontSize: compact ? 23 : 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: compact ? 12 : 13,
                          color: AppColors.white.withOpacity(0.92),
                        ),
                        children: [
                          const TextSpan(text: 'Msimbo umetumwa kwa '),
                          TextSpan(
                            text: (widget.identifier != null && widget.identifier!.contains('@'))
                                ? widget.identifier!
                                : widget.phone,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, compact ? 16 : 22, hPad, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - (compact ? 32 : 38)),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: AppColors.blueTintSoft,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.blueTint),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 16,
                                      color: AppColors.amberDark,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'Uthibitisho',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: List.generate(6, (index) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: index == 5 ? 0 : 10),
                                    child: TextFormField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        filled: false,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.border),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.border),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.blue, width: 2),
                                        ),
                                      ),
                                      onChanged: (value) => _onDigitChanged(value, index),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_message != null && _message!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              AuthNote(
                                icon: Icons.mark_email_read_outlined,
                                text: _message!,
                              ),
                            ],
                            if (authState.error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.amberTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  authState.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 26),
                            AuthPrimaryButton(
                              label: 'Thibitisha na Uendelee',
                              icon: Icons.verified_rounded,
                              loading: authState.isLoading,
                              onPressed: !isComplete ? null : _handleVerify,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: _secondsLeft > 0
                                  ? Text(
                                      'Tuma tena baada ya ${_secondsLeft}s',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: _handleResend,
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Tuma msimbo tena'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          BottomWave(height: waveHeight, color: AppColors.blue),
        ],
      ),
    );
  }
}
