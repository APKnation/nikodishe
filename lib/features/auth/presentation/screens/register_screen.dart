import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;
  final String? initialPhone;
  final String? redirectTo;

  const RegisterScreen({super.key, this.initialRole = UserRole.renter, this.initialPhone, this.redirectTo});

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
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
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
                                    onPressed: () => context.go('/auth/phone'),
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.blueTintSoft,
                                      foregroundColor: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kamilisha usajili',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Taarifa chache tu ili uanze.',
                                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _label('Jina kamili'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  hintText: 'Mfano: Juma Said',
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                  filled: true,
                                  fillColor: AppColors.surfaceSubtle.withOpacity(0.6),
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
                                readOnly: widget.initialPhone != null && widget.initialPhone!.isNotEmpty,
                                decoration: InputDecoration(
                                  hintText: '7XX XXX XXX',
                                  prefixIcon: const Icon(Icons.phone_android_outlined),
                                  prefixText: '+255 ',
                                  filled: true,
                                  fillColor: AppColors.surfaceSubtle.withOpacity(0.6),
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
                                decoration: InputDecoration(
                                  hintText: 'Mfano: Mwenge, Dar es Salaam',
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                  filled: true,
                                  fillColor: AppColors.surfaceSubtle.withOpacity(0.6),
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
                                decoration: InputDecoration(
                                  hintText: 'Huongeza uaminifu wa akaunti',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  filled: true,
                                  fillColor: AppColors.surfaceSubtle.withOpacity(0.6),
                                ),
                              ),
                              if (authState.error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.amberTint.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.amber.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    authState.error!,
                                    style: const TextStyle(color: AppColors.primaryDark, height: 1.35),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 54,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                                        )
                                      : const Text('Kamilisha na Ingia'),
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
