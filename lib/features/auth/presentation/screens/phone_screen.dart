import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blueTintSoft, AppColors.white, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.handshake_rounded,
                            color: AppColors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Karibu Kodisha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ingia kwa urahisi ili kukodi au kusimamia vifaa. Tumia barua pepe au namba ya simu yako.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Barua pepe au namba ya simu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
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
                                  color: AppColors.primary,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                final v = (value ?? '').trim();
                                if (v.isEmpty) {
                                  return 'Weka barua pepe au namba ya simu';
                                }
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
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.amberTint.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.amber.withOpacity(0.35)),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.verified_user_outlined, size: 18, color: AppColors.amberDark),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tutakutumia msimbo wa uthibitisho (OTP) ili kuingia kwa usalama.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.primaryDark,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
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
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                                ),
                                child: Text(
                                  authState.error!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13, height: 1.35),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Endelea',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded, size: 20),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        'Kwa kuendelea, unakubali kutumia mfumo kwa usalama. Akaunti za wenye vifaa huundwa na msimamizi wa mfumo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
