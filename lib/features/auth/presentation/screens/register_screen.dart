import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({super.key, this.initialRole = UserRole.renter});

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
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fungua Akaunti ya Mteja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Jisajili kama mteja',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.blueTintSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Wateja hujisajili hapa ili kuona na kukodi vifaa vyote vilivyopo kwenye dashibodi ya pamoja. Akaunti za wenye vifaa huongezwa na Super Admin pekee.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Jina kamili'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Mfano: Juma Said',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (val) {
                              final v = val?.trim() ?? '';
                              if (v.isEmpty) return 'Tafadhali ingiza jina';
                              if (v.length < 3) return 'Jina liwe na angalau herufi 3';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Namba ya simu'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '7XX XXX XXX',
                              prefixIcon: Icon(Icons.phone_android_outlined),
                              prefixText: '+255 ',
                            ),
                            validator: (val) {
                              final v = val?.trim() ?? '';
                              if (v.isEmpty) return 'Tafadhali ingiza namba ya simu';
                              if (v.length < 9) return 'Namba ya simu si sahihi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Eneo unaloishi'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _locationController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Mfano: Mwenge, Dar es Salaam',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (val) {
                              if ((val?.trim() ?? '').isEmpty) return 'Tafadhali ingiza eneo';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Namba ya NIDA (hiari)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nidaController,
                            decoration: const InputDecoration(
                              hintText: 'Huongeza uaminifu wa akaunti',
                              prefixIcon: Icon(Icons.credit_card_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (authState.error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amberTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.amber.withOpacity(0.5)),
                        ),
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: AppColors.primaryDark, height: 1.35),
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleRegister,
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Unda Akaunti ya Mteja'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tayari una akaunti? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/auth/phone'),
                          child: const Text(
                            'Ingia',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
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
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
