import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/bottom_wave.dart';
import '../../../../core/widgets/wave_header.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

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
        (size.height * (compact ? 0.27 : 0.29)).clamp(166.0, 250.0).toDouble();
    final double waveHeight = (size.height * 0.12).clamp(70.0, 112.0).toDouble();
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
                children: [
                  Center(
                    child: LayoutBuilder(
                      builder: (context, inner) {
                        final logo = AppLogo.responsiveSize(
                          inner.maxWidth,
                          fraction: 0.62,
                          minWidth: 170,
                          maxWidth: 250,
                        );
                        return AppLogo(
                          width: logo.width,
                          height: logo.height,
                          radius: compact ? 14 : 18,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 4,
                    child: IconButton(
                      onPressed: () => context.go('/auth/phone'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white.withOpacity(0.18),
                        foregroundColor: AppColors.white,
                      ),
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
                  padding: EdgeInsets.fromLTRB(hPad, compact ? 16 : 22, hPad, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - (compact ? 32 : 38)),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'USAJILI MPYA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _label('Jina kamili'),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: _underlineDecoration(
                                  hint: 'Mfano: Juma Said',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (val) {
                                  final v = val?.trim() ?? '';
                                  if (v.isEmpty) return 'Tafadhali ingiza jina';
                                  if (v.length < 3) return 'Jina liwe na angalau herufi 3';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _label('Namba ya simu'),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                readOnly: widget.initialPhone != null && widget.initialPhone!.isNotEmpty,
                                decoration: _underlineDecoration(
                                  hint: '7XX XXX XXX',
                                  icon: Icons.phone_android_outlined,
                                ),
                                validator: (val) {
                                  final v = val?.trim() ?? '';
                                  if (v.isEmpty) return 'Tafadhali ingiza namba ya simu';
                                  if (v.length < 9) return 'Namba ya simu si sahihi';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _label('Eneo unaloishi'),
                              TextFormField(
                                controller: _locationController,
                                textCapitalization: TextCapitalization.words,
                                decoration: _underlineDecoration(
                                  hint: 'Mfano: Mwenge, Dar es Salaam',
                                  icon: Icons.location_on_outlined,
                                ),
                                validator: (val) {
                                  if ((val?.trim() ?? '').isEmpty) return 'Tafadhali ingiza eneo';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _label('Namba ya NIDA (hiari)'),
                              TextFormField(
                                controller: _nidaController,
                                decoration: _underlineDecoration(
                                  hint: 'Huongeza uaminifu wa akaunti',
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                              if (authState.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.amberTint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    authState.error!,
                                    style: const TextStyle(color: AppColors.primaryDark, height: 1.35),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 54,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handleRegister,
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
                                            color: AppColors.white,
                                          ),
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
                );
              },
            ),
          ),
          BottomWave(height: waveHeight, color: AppColors.blue),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _underlineDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      filled: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.blue, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.amberDark),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.amberDark, width: 2),
      ),
    );
  }
}
