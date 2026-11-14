import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final UserRole role;
  final String? redirectTo;
  final String? identifier;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    this.redirectTo,
    this.identifier,
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

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 38),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.blueTintSoft,
                                    foregroundColor: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Thibitisha OTP',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                          children: [
                                            const TextSpan(text: 'Msimbo umetumwa kwa '),
                                            TextSpan(
                                              text: (widget.identifier != null && widget.identifier!.contains('@'))
                                                  ? widget.identifier!
                                                  : widget.phone,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: List.generate(6, (index) {
                                final filled = _controllers[index].text.isNotEmpty;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                                    child: SizedBox(
                                      height: 58,
                                      child: TextFormField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: '',
                                          contentPadding: EdgeInsets.zero,
                                          fillColor: filled
                                              ? AppColors.blueTintSoft
                                              : AppColors.surfaceSubtle.withOpacity(0.6),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(
                                              color: filled ? AppColors.primary.withOpacity(0.5) : AppColors.border,
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                          ),
                                        ),
                                        onChanged: (value) => _onDigitChanged(value, index),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.amberTint.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.amber.withOpacity(0.35)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.amberDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (widget.identifier != null && widget.identifier!.contains('@'))
                                          ? 'Msimbo umetumwa kwenye simu ya akaunti. Kwa majaribio tumia: 123456'
                                          : 'Kwa majaribio tumia msimbo: 123456',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (authState.error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.amber.withOpacity(0.35)),
                                ),
                                child: Text(
                                  authState.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: (!isComplete || authState.isLoading) ? null : _handleVerify,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Thibitisha na Uendelee',
                                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
