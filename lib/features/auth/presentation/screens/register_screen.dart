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

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;
  final String? initialPhone;
  final String? redirectTo;

  const RegisterScreen({
    super.key,
    this.initialRole = UserRole.renter,
    this.initialPhone,
    this.redirectTo,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _nidaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.initialPhone ?? '';
    if (p.startsWith('+255')) {
      _phoneController.text = p.substring(4);
    } else if (p.startsWith('255')) {
      _phoneController.text = p.substring(3);
    } else if (p.startsWith('0')) {
      _phoneController.text = p.substring(1);
    } else {
      _phoneController.text = p;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _nidaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final phone = '+255${_phoneController.text.trim()}';

    await ref.read(authProvider.notifier).registerUser(
          name: _nameController.text.trim(),
          phone: phone,
          role: UserRole.renter,
          location: _locationController.text.trim(),
          whatsapp: phone,
          nidaNumber: _nidaController.text.trim().isNotEmpty
              ? _nidaController.text.trim()
              : null,
        );

    final authState = ref.read(authProvider);
    if (!mounted) return;
    if (authState.user != null && authState.error == null) {
      context.go(widget.redirectTo ?? '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.sizeOf(context);
    final bool compact = size.height < 720 || size.width < 360;
    final double headerHeight =
        (size.height * (compact ? 0.30 : 0.32)).clamp(175.0, 275.0).toDouble();
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
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: IconButton(
                        onPressed: () => context.go('/auth/phone'),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white.withOpacity(0.9),
                          foregroundColor: AppColors.orangeDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, compact ? 18 : 24, hPad, 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - (compact ? 34 : 42)),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: AuthEntrance(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Jisajili',
                                  style: TextStyle(
                                    fontSize: compact ? 26 : 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.orangeDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Unda akaunti yako kwa taarifa chache tu.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const AuthSectionTitle(
                                  title: 'TAARIFA BINAFSI',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                                AuthField(
                                  controller: _nameController,
                                  label: 'Jina kamili',
                                  hint: 'Mfano: Juma Said',
                                  icon: Icons.person_outline_rounded,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (val) {
                                    final v = val?.trim() ?? '';
                                    if (v.isEmpty) return 'Tafadhali ingiza jina';
                                    if (v.length < 3) return 'Jina liwe na angalau herufi 3';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                AuthField(
                                  controller: _phoneController,
                                  label: 'Namba ya simu',
                                  hint: '7XX XXX XXX',
                                  icon: Icons.phone_android_outlined,
                                  keyboardType: TextInputType.phone,
                                  readOnly: widget.initialPhone != null && widget.initialPhone!.isNotEmpty,
                                  validator: (val) {
                                    final v = val?.trim() ?? '';
                                    if (v.isEmpty) return 'Tafadhali ingiza namba ya simu';
                                    if (v.length < 9) return 'Namba ya simu si sahihi';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 22),
                                const AuthSectionTitle(
                                  title: 'MAHALI',
                                  icon: Icons.location_on_outlined,
                                ),
                                const SizedBox(height: 14),
                                AuthField(
                                  controller: _locationController,
                                  label: 'Eneo unaloishi',
                                  hint: 'Mfano: Mwenge, Dar es Salaam',
                                  icon: Icons.location_on_outlined,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (val) {
                                    if ((val?.trim() ?? '').isEmpty) return 'Tafadhali ingiza eneo';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 22),
                                const AuthSectionTitle(
                                  title: 'UTHIBITISHO (HIARI)',
                                  icon: Icons.verified_user_outlined,
                                ),
                                const SizedBox(height: 14),
                                AuthField(
                                  controller: _nidaController,
                                  label: 'Namba ya NIDA',
                                  hint: 'Huongeza uaminifu wa akaunti',
                                  icon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                                if (authState.error != null) ...[
                                  const SizedBox(height: 18),
                                  AuthErrorBox(message: authState.error!),
                                ],
                                const SizedBox(height: 26),
                                AuthPrimaryButton(
                                  label: 'Kamilisha na Ingia',
                                  icon: Icons.check_rounded,
                                  loading: authState.isLoading,
                                  onPressed: _handleRegister,
                                ),
                                const SizedBox(height: 14),
                                const Center(
                                  child: Text(
                                    'Unaweza kuongeza NIDA baadaye kwenye wasifu.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textTertiary,
                                      height: 1.4,
                                    ),
                                  ),
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
          BottomWave(height: waveHeight, color: AppColors.orange),
        ],
      ),
    );
  }
}
