import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({
    super.key,
    this.initialRole = UserRole.renter,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late UserRole _selectedRole;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _nidaController = TextEditingController();

  String _selectedCategory = 'Vifaa vya Sherehe';

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _nidaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = '+255${_phoneController.text.trim()}';
    final whatsapp = _whatsappController.text.trim().isNotEmpty
        ? '+255${_whatsappController.text.trim()}'
        : phone;

    await ref.read(authProvider.notifier).registerUser(
          name: _nameController.text.trim(),
          phone: phone,
          role: _selectedRole,
          location: _locationController.text.trim(),
          whatsapp: whatsapp,
          instagram: _instagramController.text.trim().isNotEmpty
              ? _instagramController.text.trim()
              : null,
        );

    // Send OTP
    await ref.read(authProvider.notifier).sendOtp(phone);

    if (mounted) {
      context.push('/auth/otp', extra: {
        'phone': phone,
        'role': _selectedRole,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isOwner = _selectedRole == UserRole.owner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Unda Akaunti Mpya'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Prompt
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Karibu Kodisha Tanzania 🇹🇿',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Chagua aina ya akaunti unayotaka kufungua:',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Role Selector Tabs (Customer vs Owner)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildRoleTab(
                        role: UserRole.renter,
                        title: 'Mteja / Mkodishaji',
                        icon: Icons.person,
                        subtitle: 'Kukodi vifaa',
                      ),
                      _buildRoleTab(
                        role: UserRole.owner,
                        title: 'Mwenye Vifaa',
                        icon: Icons.storefront,
                        subtitle: 'Kukodisha vifaa vyako',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Role Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isOwner
                        ? Colors.amber.shade50
                        : Colors.teal.shade50.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOwner
                          ? Colors.amber.shade300
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOwner ? Icons.business_center : Icons.shopping_bag_outlined,
                        color: isOwner ? Colors.brown : AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isOwner
                              ? 'Akaunti ya Mwenye Vifaa: Utaweza kuweka matangazo ya vifaa vyako, kupokea bookings, na kukusanya malipo.'
                              : 'Akaunti ya Mteja: Utaweza kutafuta vifaa vya ujenzi, sherehe na kumbi, kulinganisha bei na kuweka booking.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOwner ? Colors.brown.shade800 : AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Full Name / Business Name
                Text(
                  isOwner ? 'Jina la Biashara au Jina Kamili *' : 'Jina Kamili *',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: isOwner
                        ? 'Mfano: Amina Event & Tent Rentals'
                        : 'Mfano: John Juma Mwangi',
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tafadhali ingiza jina';
                    }
                    if (val.trim().length < 3) {
                      return 'Jina liwe na angalau herufi 3';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Phone Number
                const Text(
                  'Namba ya Simu (M-Pesa / Tigo / Airtel) *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixText: '+255 ',
                    prefixStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    hintText: '7XX XXX XXX',
                    prefixIcon: Icon(Icons.phone_android, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tafadhali ingiza namba ya simu';
                    }
                    if (val.trim().length < 9) {
                      return 'Namba ya simu iwe na angalau tarakimu 9';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Location / City
                Text(
                  isOwner ? 'Mkoa na Eneo la Yard / Ofisi *' : 'Mkoa na Eneo Unaloishi *',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: isOwner
                        ? 'Mfano: Sinza Kijiweni, Dar es Salaam'
                        : 'Mfano: Mwenge, Dar es Salaam',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tafadhali ingiza eneo lako';
                    }
                    return null;
                  },
                ),

                // Additional Owner Fields
                if (isOwner) ...[
                  const SizedBox(height: 18),

                  // WhatsApp Number for Owner
                  const Text(
                    'Namba ya WhatsApp ya Biashara (Hiari)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixText: '+255 ',
                      hintText: '7XX XXX XXX (Kama ni tofauti na namba kuu)',
                      prefixIcon: Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Equipment Category
                  const Text(
                    'Aina Kuu ya Vifaa Unavyomiliki',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Vifaa vya Sherehe', child: Text('🎉 Vifaa vya Sherehe')),
                      DropdownMenuItem(value: 'Vifaa vya Ujenzi', child: Text('🏗️ Vifaa vya Ujenzi')),
                      DropdownMenuItem(value: 'Ukumbi / Venues', child: Text('🏛️ Ukumbi / Venues')),
                      DropdownMenuItem(value: 'Vifaa vya Aina Zote', child: Text('📦 Vifaa vya Aina Zote')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),

                  const SizedBox(height: 18),

                  // Instagram Handle
                  const Text(
                    'Akaunti ya Instagram ya Biashara (Hiari)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      hintText: 'Mfano: @vifaa_vya_ujenzi_tz',
                      prefixIcon: Icon(Icons.camera_alt_outlined, color: Color(0xFFE1306C)),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 18),

                  // Customer NIDA (Optional)
                  const Text(
                    'Namba ya NIDA / Kitambulisho (Hiari)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nidaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Mfano: 19900101-XXXXX-XXXXX-XX',
                      prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isOwner ? 'Jisajili kama Mwenye Vifaa' : 'Jisajili kama Mteja',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Switch to Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Una akaunti tayari? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/auth/phone'),
                        child: const Text(
                          'Ingia Hapa (Login)',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required UserRole role,
    required String title,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.textPrimary : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

