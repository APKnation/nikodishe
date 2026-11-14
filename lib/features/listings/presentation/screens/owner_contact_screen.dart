import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/models/user_model.dart';
import '../../providers/listings_provider.dart';

class OwnerContactScreen extends ConsumerWidget {
  final String listingId;

  const OwnerContactScreen({super.key, required this.listingId});

  UserModel _getOwner(String ownerId, String ownerName) {
    try {
      return mockUsers.firstWhere(
        (u) => u.id == ownerId || u.name == ownerName,
      );
    } catch (_) {
      return UserModel(
        id: ownerId,
        name: ownerName,
        phone: '+255712345678',
        whatsapp: '+255712345678',
        instagram: '@kodisha_owner_tz',
        facebook: '$ownerName Rentals',
        tiktok: '@kodisha_tz',
        role: UserRole.owner,
        location: 'Dar es Salaam, Tanzania',
        createdAt: DateTime.now(),
      );
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label imenakiliwa kwenye clipboard!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulateExternalLaunch(
    BuildContext context,
    String platform,
    String value,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.open_in_new,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Fungua $platform',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Unakaribia kufungua $platform kwa anwani/namba: $value.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Rudi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Inafungua $platform ($value)...'),
                        ),
                      );
                    },
                    child: const Text('Fungua Sasa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingByIdProvider(listingId));
    final ownerName = listing?.ownerName ?? 'Mwenye Kifaa';
    final ownerId = listing?.ownerId ?? 'user_001';
    final owner = _getOwner(ownerId, ownerName);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mawasiliano ya Mwenye Kifaa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: const Icon(
                          Icons.person,
                          size: 54,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    owner.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Mwenye Vifaa Aliyethibitishwa',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (owner.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          owner.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Item Context Card (Kifaa anachoulizia)
            if (listing != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.orangeTintSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.handyman,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kuhusu Kifaa:',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            listing.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Direct Contact Methods Header
            const Text(
              'Mawasiliano ya Moja kwa Moja',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // WhatsApp Button
            _buildContactCard(
              title: 'WhatsApp Chat & Call',
              subtitle: owner.whatsapp ?? owner.phone,
              icon: Icons.chat_bubble_outline,
              iconBgColor: AppColors.primary,
              actionLabel: 'Fungua WhatsApp',
              onTap: () => _simulateExternalLaunch(
                context,
                'WhatsApp',
                owner.whatsapp ?? owner.phone,
              ),
              onCopy: () => _copyToClipboard(
                context,
                owner.whatsapp ?? owner.phone,
                'Namba ya WhatsApp',
              ),
            ),

            const SizedBox(height: 10),

            // Normal Voice Phone Call
            _buildContactCard(
              title: 'Piga Simu ya Kawaida',
              subtitle: owner.phone,
              icon: Icons.phone,
              iconBgColor: AppColors.primary,
              actionLabel: 'Piga Sasa',
              onTap: () =>
                  _simulateExternalLaunch(context, 'Piga Simu', owner.phone),
              onCopy: () =>
                  _copyToClipboard(context, owner.phone, 'Namba ya Simu'),
            ),

            const SizedBox(height: 10),

            // SMS Message
            _buildContactCard(
              title: 'Tuma Ujumbe wa SMS',
              subtitle: owner.phone,
              icon: Icons.message_outlined,
              iconBgColor: AppColors.orangeSoft,
              actionLabel: 'Tuma SMS',
              onTap: () => _simulateExternalLaunch(context, 'SMS', owner.phone),
              onCopy: () =>
                  _copyToClipboard(context, owner.phone, 'Namba ya Simu'),
            ),

            const SizedBox(height: 24),

            // Social Media Accounts Section
            const Text(
              'Akaunti za Mitandao ya Kijamii',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Instagram
                  if (owner.instagram != null) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.amberDark.withOpacity(0.12),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.amberDark,
                        ),
                      ),
                      title: const Text(
                        'Instagram',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        owner.instagram!,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => _simulateExternalLaunch(
                        context,
                        'Instagram',
                        owner.instagram!,
                      ),
                    ),
                    const Divider(height: 1),
                  ],

                  // Facebook
                  if (owner.facebook != null) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: const Icon(
                          Icons.facebook,
                          color: AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Facebook',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        owner.facebook!,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => _simulateExternalLaunch(
                        context,
                        'Facebook',
                        owner.facebook!,
                      ),
                    ),
                    const Divider(height: 1),
                  ],

                  // TikTok
                  if (owner.tiktok != null) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.orangeDark,
                        ),
                      ),
                      title: const Text(
                        'TikTok',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        owner.tiktok!,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => _simulateExternalLaunch(
                        context,
                        'TikTok',
                        owner.tiktok!,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Availability & Safety Tip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.amberTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amber.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    color: AppColors.amber,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Muda wa kupokea simu: 06:00 Asubuhi - 09:00 Usiku. Kwa usalama wako, kagua kifaa kabla ya kulipa malipo ya mwisho.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.orangeDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required String actionLabel,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBgColor,
            radius: 22,
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Nakili Namba',
            onPressed: onCopy,
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconBgColor,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
