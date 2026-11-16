import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/ai_bounce_icon.dart';
import '../../../../data/services/api_service.dart';
import '../../../auth/providers/auth_provider.dart';

/// Uchambuzi wa data ya biashara/project kwa kutumia Kodisha AI.
/// Backend inahakikisha owner anaona data yake pekee, staff anaona jukwaa zima.
class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _focusController = TextEditingController();

  bool _loading = false;
  String? _analysis;
  String? _scope;
  String? _error;

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.aiAnalyze(focus: _focusController.text);
      if (!mounted) return;
      setState(() {
        _analysis = result['analysis'] as String?;
        _scope = result['scope'] as String?;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final isSw = lang == AppLanguage.sw;
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.role.name == 'owner';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isSw ? 'Uchambuzi wa AI' : 'AI Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.onColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const AiBounceIcon(size: 36, bounceHeight: 3),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSw
                              ? 'Chambua data ya biashara yako kwa AI'
                              : 'Analyze your business data with AI',
                          style: const TextStyle(
                            color: AppColors.onColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSw
                        ? 'AI itasoma vifaa, bookings, malipo na tathmini zilizopo '
                            'kwenye mfumo kisha ikuletee muhtasari na mapendekezo.'
                        : 'AI reads your listings, bookings, payments and reviews, '
                            'then returns a summary with recommendations.',
                    style: TextStyle(
                      color: AppColors.onColor.withOpacity(0.9),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onColor.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSw
                            ? 'Uchambuzi wa vifaa na mapato yako pekee'
                            : 'Analysis of your listings & revenue only',
                        style: const TextStyle(
                          color: AppColors.onColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSw ? 'Unataka kulenga nini? (hiari)' : 'What should we focus on? (optional)',
              style:  TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _focusController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: isSw
                    ? 'Mf. "Kwa nini bookings zimepungua?" au "Mapato yangu yanaongezeka vipi?"'
                    : 'e.g. "Why are bookings dropping?" or "How can I grow revenue?"',
                hintStyle:  TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:  BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:  BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _analyze,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onColor,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _loading
                      ? (isSw ? 'AI inachambua data...' : 'AI is analyzing...')
                      : (isSw ? 'Chambua kwa AI' : 'Analyze with AI'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.amberTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.amber),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style:  TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_analysis != null && _analysis!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueDark.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                         Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isSw ? 'Ripoti ya Kodisha AI' : 'Kodisha AI Report',
                            style:  TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_scope != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _scope == 'platform'
                                  ? (isSw ? 'Jukwaa lote' : 'Platform')
                                  : (isSw ? 'Biashara yako' : 'Your business'),
                              style:  TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 24),
                    SelectableText(
                      _analysis!,
                      style:  TextStyle(
                        fontSize: 13.5,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.blueTintSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                           Icon(
                            Icons.verified_outlined,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isSw
                                  ? 'Imetokana na data halisi ya mfumo. Hakikisha maamuzi makubwa na data ya sasa.'
                                  : 'Based on real system data. Verify major decisions against live data.',
                              style:  TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
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
    );
  }
}
