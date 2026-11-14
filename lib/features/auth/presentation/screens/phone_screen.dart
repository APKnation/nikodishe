import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_background.dart';
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
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
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
                              Center(
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.primary, AppColors.primaryDark],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.storefront_rounded, color: AppColors.white, size: 34),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Karibu Kodisha',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ingia kwa barua pepe au namba ya simu yako.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 24),
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary.withOpacity(0.9),
                                        height: 1.35,
                                      ),
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
                              const SizedBox(height: 20),
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
                              Text(
                                'Kwa kuendelea, unakubali masharti ya matumizi.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary.withOpacity(0.95), height: 1.4),
                              ),
                            ],
                          ),
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
