import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/wave_header.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  final String? redirectTo;
  const PhoneScreen({super.key, this.redirectTo});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String value) => value.contains('@');

  Future<void> _handleContinue() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final identifier = _identifierController.text.trim();
    final resolvedPhone = await ref.read(authProvider.notifier).sendOtp(identifier);
    final auth = ref.read(authProvider);
    if (!mounted) return;
    if (resolvedPhone != null && auth.error == null) {
      context.push('/auth/otp', extra: {
        'phone': resolvedPhone,
        'identifier': identifier,
        'role': UserRole.renter, // actual role resolved after verify
        'redirectTo': widget.redirectTo,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            WaveHeader(
              height: 262,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withOpacity(0.25),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kodisha',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kukodi na kusimamia vifaa kwa urahisi',
                      style: TextStyle(fontSize: 13, color: AppColors.white.withOpacity(0.88)),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -34),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Karibu tena',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ingia kwa barua pepe au namba ya simu.',
                          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Barua pepe au namba ya simu',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleContinue(),
                          decoration: InputDecoration(
                            hintText: 'mfano: jina@email.com au 07XXXXXXXX',
                            prefixIcon: Icon(
                              _looksLikeEmail(_identifierController.text)
                                  ? Icons.alternate_email_rounded
                                  : Icons.phone_iphone_rounded,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceSubtle.withOpacity(0.6),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final v = (value ?? '').trim();
                            if (v.isEmpty) return 'Weka barua pepe au namba ya simu';
                            if (v.contains('@')) {
                              final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                              if (!emailOk) return 'Weka barua pepe sahihi';
                            } else {
                              final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
                              if (digits.length < 9) return 'Weka namba ya simu sahihi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Tutakutumia msimbo wa uthibitisho (OTP) kwa usalama.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.9), height: 1.35),
                              ),
                            ),
                          ],
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
                              style: const TextStyle(color: AppColors.primaryDark, fontSize: 13, height: 1.35),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleContinue,
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
                                    'Endelea',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Kwa kuendelea, unakubali masharti ya matumizi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary.withOpacity(0.95), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
