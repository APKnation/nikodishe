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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isOwnerMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _fullPhone() => '+255${_phoneController.text.trim()}';

  Future<void> _handleCustomerContinue() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final phone = _fullPhone();
    await ref.read(authProvider.notifier).sendOtp(phone);
    final error = ref.read(authProvider).error;
    if (mounted && error == null) {
      context.push('/auth/otp', extra: {'phone': phone, 'role': UserRole.renter});
    }
  }

  Future<void> _handleOwnerLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final phone = _fullPhone();
    final password = _passwordController.text.trim();
    await ref.read(authProvider.notifier).loginOwner(phone: phone, password: password);
    final auth = ref.read(authProvider);
    if (!mounted) return;
    if (auth.user != null) {
      if (auth.user!.role == UserRole.owner) {
        context.go('/owner/home');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          size: 42,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kodisha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isOwnerMode
                          ? 'Ingia kama mwenye kifaa (akaunti huundwa na super admin)'
                          : 'Gundua na kodisha vifaa kutoka kwa wamiliki mbalimbali',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blueTintSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeChip(
                              label: 'Mteja',
                              selected: !_isOwnerMode,
                              icon: Icons.shopping_bag_outlined,
                              onTap: () => setState(() => _isOwnerMode = false),
                            ),
                          ),
                          Expanded(
                            child: _ModeChip(
                              label: 'Mwenye Kifaa',
                              selected: _isOwnerMode,
                              icon: Icons.storefront_outlined,
                              onTap: () => setState(() => _isOwnerMode = true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Namba ya simu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 9,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            decoration: InputDecoration(
                              hintText: '7XX XXX XXX',
                              counterText: '',
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🇹🇿', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      '+255',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      width: 1,
                                      height: 22,
                                      color: AppColors.border,
                                    ),
                                  ],
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tafadhali ingiza namba ya simu';
                              }
                              if (value.trim().length < 9) {
                                return 'Namba ya simu haijakamilika';
                              }
                              return null;
                            },
                          ),

                          if (_isOwnerMode) ...[
                            const SizedBox(height: 14),
                            const Text(
                              'Nenosiri',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Weka nenosiri ulilopewa na msimamizi',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (!_isOwnerMode) return null;
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tafadhali ingiza nenosiri';
                                }
                                if (value.trim().length < 4) {
                                  return 'Nenosiri si sahihi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.amberTint,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.amber.withOpacity(0.4)),
                              ),
                              child: const Text(
                                'Wamiliki wa vifaa huongezwa na Super Admin pekee na hupewa nenosiri la awali (mf. Kodisha@123).',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.35),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.blueTintSoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'Wateja hujisajili kwa OTP. Dashibodi ya pamoja inaonyesha vifaa vyote kutoka kwa wamiliki tofauti.',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                              ),
                            ),
                          ],

                          if (authState.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              authState.error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ],

                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : (_isOwnerMode ? _handleOwnerLogin : _handleCustomerContinue),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text(_isOwnerMode ? 'Ingia kama Mwenye Kifaa' : 'Endelea kwa OTP'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!_isOwnerMode) ...[
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => context.push('/auth/register', extra: UserRole.renter),
                        child: const Text('Huna akaunti ya mteja? Jisajili hapa'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.border : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
