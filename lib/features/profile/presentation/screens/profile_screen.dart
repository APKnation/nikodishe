import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        ref.read(authProvider.notifier).updateProfile(photoUrl: photo.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Picha ya wasifu imebadilishwa kikamilifu!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imeshindwa kufungua picha: $e')),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    final lang = ref.read(localeProvider);
    final nameController = TextEditingController(text: user?.name ?? '');
    final locationController = TextEditingController(text: user?.location ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.get(lang, 'edit_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: lang == AppLanguage.sw ? 'Jina Kamili' : 'Full Name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: lang == AppLanguage.sw ? 'Eneo / Mji (Mfano: Dar es Salaam)' : 'Location / City',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get(lang, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(authProvider.notifier).updateProfile(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                  );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    lang == AppLanguage.sw ? 'Taarifa zimebadilishwa!' : 'Profile updated successfully!',
                  ),
                ),
              );
            },
            child: Text(lang == AppLanguage.sw ? 'Hifadhi' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLang = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chagua Lugha / Choose Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('🇹🇿', style: TextStyle(fontSize: 24)),
              title: const Text('Kiswahili', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Lugha ya Taifa (Default)'),
              trailing: currentLang == AppLanguage.sw
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLanguage(AppLanguage.sw);
                Navigator.of(ctx).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('International language'),
              trailing: currentLang == AppLanguage.en
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLanguage(AppLanguage.en);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'my_profile')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 84,
                          height: 84,
                          color: AppColors.primaryLight,
                          child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                              ? AppNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  placeholderIcon: Icons.person,
                                )
                              : const Icon(Icons.person, size: 50, color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickProfilePhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? (lang == AppLanguage.sw ? 'Mtumiaji wa Kodisha' : 'Kodisha User'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? '+255 700 000 000',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role == UserRole.owner
                          ? AppStrings.get(lang, 'role_owner')
                          : AppStrings.get(lang, 'role_renter'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(context, user),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(AppStrings.get(lang, 'edit_profile')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          final newRole = user?.role == UserRole.owner
                              ? UserRole.renter
                              : UserRole.owner;
                          ref.read(authProvider.notifier).switchRole(newRole);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newRole == UserRole.owner
                                    ? 'Akaunti yako sasa ni ya Mwenye Vifaa (Owner) 🏢'
                                    : 'Akaunti yako sasa ni ya Mteja (Customer) 🛒',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          user?.role == UserRole.owner
                              ? Icons.shopping_bag_outlined
                              : Icons.storefront_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          user?.role == UserRole.owner
                              ? 'Hali ya Mteja'
                              : 'Kuwa Mwenye Vifaa',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings & Options List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // FR25: Owner Dashboard & Listings
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'owner_dashboard')),
                    subtitle: Text(AppStrings.get(lang, 'owner_dashboard_sub')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/owner/dashboard'),
                  ),
                  const Divider(height: 1),

                  // FR24: Booking History
                  ListTile(
                    leading: const Icon(Icons.history, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'booking_history')),
                    subtitle: Text(AppStrings.get(lang, 'booking_history_sub')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/bookings/history'),
                  ),
                  const Divider(height: 1),

                  // Payments History
                  ListTile(
                    leading: const Icon(Icons.payment, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'payment_history')),
                    subtitle: Text(AppStrings.get(lang, 'payment_history_sub')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/payments/history'),
                  ),
                  const Divider(height: 1),

                  // Notifications
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'notifications')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/notifications'),
                  ),
                  const Divider(height: 1),

                  // FR26: Language Switcher
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'language')),
                    subtitle: Text(lang == AppLanguage.sw ? 'Kiswahili 🇹🇿' : 'English 🇬🇧'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 1),

                  // Support
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'help_support')),
                    subtitle: const Text('WhatsApp / 0700 000 000'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Huduma kwa wateja: 0700 000 000')),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // Privacy Policy
                  ListTile(
                    leading: const Icon(Icons.security, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'privacy_policy')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),

                  // About App
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.primary),
                    title: Text(AppStrings.get(lang, 'about_app')),
                    subtitle: const Text('Version 1.0.0 (Tanzania MVP)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/auth/phone');
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  AppStrings.get(lang, 'logout'),
                  style: const TextStyle(color: AppColors.error),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
