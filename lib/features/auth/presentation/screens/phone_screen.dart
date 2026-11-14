import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/bottom_wave.dart';
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
    final size = MediaQuery.sizeOf(context);
    final bool compact = size.height < 700 || size.width < 360;
    final double headerHeight =
        (size.height * (compact ? 0.34 : 0.37)).clamp(205.0, 320.0).toDouble();
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Brand logo as a soft background watermark
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0.20,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppLogo.transparentAsset,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  // Readable copy on top
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Kodisha',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 27 : 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SHEREHE  •  UJENZI  •  UKUMBI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 10.5 : 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white.withOpacity(0.95),
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, compact ? 18 : 24, hPad, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - (compact ? 34 : 40)),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'KARIBU TENA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'Barua pepe au namba ya simu',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextFormField(
                                controller: _identifierController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleContinue(),
                                decoration: InputDecoration(
                                  hintText: 'jina@email.com au 07XXXXXXXX',
                                  prefixIcon: Icon(
                                    _looksLikeEmail(_identifierController.text)
                                        ? Icons.alternate_email_rounded
                                        : Icons.phone_iphone_rounded,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                                  filled: false,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.border),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.border),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.blue, width: 2),
                                  ),
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.amberDark),
                                  ),
                                  focusedErrorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.amberDark, width: 2),
                                  ),
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
                                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.blue),
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
                                    color: AppColors.amberTint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    authState.error!,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 26),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handleContinue,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
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
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textTertiary.withOpacity(0.95),
                                  height: 1.4,
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
          BottomWave(height: waveHeight, color: AppColors.blue),
        ],
      ),
    );
  }
}
