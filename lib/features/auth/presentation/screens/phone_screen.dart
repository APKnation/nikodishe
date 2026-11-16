import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/bottom_wave.dart';
import '../../../../core/widgets/curved_divider.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

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
        'sentMessage': auth.otpMessage,
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
    final double curveHeight = (size.height * 0.045).clamp(26.0, 42.0).toDouble();
    final double hPad = size.width < 360 ? 20 : 28;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: headerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppLogo.asset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CurvedDivider(height: curveHeight),
                ),
              ],
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
                        child: AuthEntrance(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Karibu tena',
                                  style: TextStyle(
                                    fontSize: compact ? 26 : 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                 Text(
                                  'Ingia kwa usalama kwa barua pepe au namba ya simu yako.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                AuthField(
                                  controller: _identifierController,
                                  label: 'Barua pepe au namba ya simu',
                                  hint: 'jina@email.com au 07XXXXXXXX',
                                  icon: _looksLikeEmail(_identifierController.text)
                                      ? Icons.alternate_email_rounded
                                      : Icons.phone_iphone_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) => setState(() {}),
                                  onFieldSubmitted: (_) => _handleContinue(),
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
                                if (authState.isLoading) ...[
                                  const SizedBox(height: 16),
                                  const AuthNote(
                                    icon: Icons.outgoing_mail,
                                    text: 'Tunakutumia msimbo wa uthibitisho...',
                                  ),
                                ],
                                if (authState.error != null) ...[
                                  const SizedBox(height: 14),
                                  AuthErrorBox(message: authState.error!),
                                ],
                                const SizedBox(height: 24),
                                AuthPrimaryButton(
                                  label: 'Endelea',
                                  loading: authState.isLoading,
                                  onPressed: _handleContinue,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                     Icon(
                                      Icons.verified_user_outlined,
                                      size: 15,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Data yako imelindwa. Kwa kuendelea unakubali masharti.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textTertiary.withOpacity(0.95),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
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
          BottomWave(height: waveHeight, color: AppColors.blue),
        ],
      ),
    );
  }
}
