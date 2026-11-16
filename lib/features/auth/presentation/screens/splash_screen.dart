import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/app_logo.dart';

/// Ukurasa wa kwanza (landing / get started) wa Kodisha.
///
/// Muundo: logo kubwa yenye mwanga (glow), ujumbe wa brand, vipengele
/// vitatu vya huduma, na vitufe vya "Anza Sasa" na "Ingia".
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _entrance.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Heshima mapendeleo ya mtumiaji: zima animation kama amezima kwenye OS.
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      if (_float.isAnimating) _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 700;
    final horizontalPadding = size.width < 360 ? 18.0 : 24.0;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF102A6B),
              AppColors.primary,
              Color(0xFF3B6BE8),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Mapambo ya nyuma (decorative blobs) ───────────────────────
            Positioned(
              top: -110,
              right: -70,
              child: _GlowBlob(
                diameter: math.min(size.width * 0.7, 300),
                color: AppColors.onColor.withOpacity(0.10),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: _GlowBlob(
                diameter: math.min(size.width * 0.8, 340),
                color: AppColors.amber.withOpacity(0.18),
              ),
            ),
            Positioned(
              top: size.height * 0.32,
              left: -60,
              child: _GlowBlob(
                diameter: 150,
                color: AppColors.onColor.withOpacity(0.05),
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isCompact ? 12 : 20,
                      horizontalPadding,
                      isCompact ? 16 : 28,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(context),
                        SizedBox(height: isCompact ? 18 : 36),
                        _buildHero(size, isCompact),
                        SizedBox(height: isCompact ? 18 : 28),
                        _Entrance(
                          animation: _entrance,
                          interval: const Interval(
                            0.35,
                            0.85,
                            curve: Curves.easeOutCubic,
                          ),
                          offset: const Offset(0, 0.12),
                          child: _buildHeadline(size),
                        ),
                        SizedBox(height: isCompact ? 14 : 20),
                        _Entrance(
                          animation: _entrance,
                          interval: const Interval(
                            0.5,
                            0.95,
                            curve: Curves.easeOutCubic,
                          ),
                          offset: const Offset(0, 0.16),
                          child: _buildFeaturePills(),
                        ),
                        SizedBox(height: isCompact ? 22 : 34),
                        _Entrance(
                          animation: _entrance,
                          interval: const Interval(
                            0.65,
                            1.0,
                            curve: Curves.easeOutCubic,
                          ),
                          offset: const Offset(0, 0.18),
                          child: _buildActions(context),
                        ),
                        const SizedBox(height: 18),
                        _Entrance(
                          animation: _entrance,
                          interval: const Interval(
                            0.8,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                          offset: Offset.zero,
                          child: Text(
                            AppStrings.get(lang, 'landing_footer'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              letterSpacing: 0.2,
                              color: AppColors.onColor.withOpacity(0.70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sehemu ya juu: logo ndogo + jina la brand ──────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return _Entrance(
      animation: _entrance,
      interval: const Interval(0.0, 0.5, curve: Curves.easeOut),
      offset: const Offset(0, -0.2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showBadge = constraints.maxWidth >= 340;
          return Row(
            children: [
              const AppLogo(height: 34, radius: 10),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  'Kodisha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.onColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.onColor.withOpacity(0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, size: 13, color: AppColors.onColor),
                      SizedBox(width: 5),
                      Text(
                        'Tanzania',
                        style: TextStyle(
                          color: AppColors.onColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Logo kubwa inayoelea (floating hero) ───────────────────────────────
  Widget _buildHero(Size size, bool isCompact) {
    final logoWidth = math
        .min(size.width * (isCompact ? 0.58 : 0.64), 300.0)
        .clamp(190.0, 300.0)
        .toDouble();

    return _Entrance(
      animation: _entrance,
      interval: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
      offset: const Offset(0, 0.18),
      scaleFrom: 0.82,
      child: SizedBox(
        height: logoWidth / AppLogo.aspectRatio + (isCompact ? 40 : 56),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Mwanga wa nyuma
            Container(
              width: logoWidth * 0.95,
              height: logoWidth * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.onColor.withOpacity(0.22),
                    AppColors.onColor.withOpacity(0.02),
                  ],
                ),
              ),
            ),
            Container(
              width: logoWidth + (isCompact ? 26 : 38),
              height: logoWidth + (isCompact ? 26 : 38),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.onColor.withOpacity(0.16),
                  width: 1.2,
                ),
              ),
            ),
            // Logo inayoelea juu na chini kwa kimo kidogo
            AnimatedBuilder(
              animation: _float,
              builder: (context, child) {
                final dy = MediaQuery.disableAnimationsOf(context)
                    ? 0.0
                    : math.sin(_float.value * math.pi * 2) * 5.0;
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: AppLogo(
                width: logoWidth,
                height: logoWidth / AppLogo.aspectRatio,
                radius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline(Size size) {
    final lang = ref.read(localeProvider);
    final fontSize = (size.width * 0.078).clamp(26.0, 36.0).toDouble();
    return Column(
      children: [
        Text(
          AppStrings.get(lang, 'landing_headline'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.get(lang, 'landing_sub'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onColor.withOpacity(0.82),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePills() {
    final lang = ref.read(localeProvider);
    final isSw = lang == AppLanguage.sw;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _FeaturePill(
          icon: Icons.celebration_rounded,
          label: isSw ? 'Sherehe' : 'Events',
        ),
        _FeaturePill(
          icon: Icons.construction_rounded,
          label: isSw ? 'Ujenzi' : 'Construction',
        ),
        _FeaturePill(
          icon: Icons.meeting_room_rounded,
          label: isSw ? 'Ukumbi' : 'Venues',
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final lang = ref.read(localeProvider);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onColor,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.get(lang, 'get_started'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => context.push(
              '/auth/phone',
              extra: {'redirectTo': '/home'},
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onColor,
              side: BorderSide(color: AppColors.onColor.withOpacity(0.55)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppStrings.get(lang, 'have_account'),
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

/// Duara laini la mwanga linalotumika kama mapambo ya nyuma.
class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}

/// Kipengele kidogo cha huduma (pill).
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.onColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.onColor.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kioanisho cha kuingia (fade + slide + scale) kwa awamu (stagger).
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.animation,
    required this.interval,
    required this.child,
    this.offset = const Offset(0, 0.15),
    this.scaleFrom,
  });

  final Animation<double> animation;
  final Interval interval;
  final Widget child;
  final Offset offset;
  final double? scaleFrom;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    Widget result = FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: offset, end: Offset.zero).animate(curved),
        child: child,
      ),
    );

    if (scaleFrom != null) {
      result = ScaleTransition(
        scale: Tween<double>(begin: scaleFrom, end: 1.0).animate(curved),
        child: result,
      );
    }

    return result;
  }
}
