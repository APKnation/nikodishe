import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Full-screen branded background for auth screens.
/// Covers the entire phone screen with a rich gradient, soft glows
/// and decorative wave shapes, while [child] sits on top (centered).
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base: full-screen gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.blueSoft,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Soft glows
        Positioned(
          top: -size.width * 0.35,
          right: -size.width * 0.25,
          child: _Glow(
            size: size.width * 0.95,
            color: AppColors.white.withOpacity(0.10),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.45,
          left: -size.width * 0.3,
          child: _Glow(
            size: size.width * 1.2,
            color: AppColors.amber.withOpacity(0.12),
          ),
        ),

        // Decorative waves (top + bottom)
        Positioned(
          top: -size.height * 0.03,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ClipPath(
              clipper: _TopWaveClipper(),
              child: Container(
                height: size.height * 0.28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.white.withOpacity(0.10),
                      AppColors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ClipPath(
              clipper: _TopWaveClipper(),
              child: Container(
                height: size.height * 0.22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.35),
                      AppColors.primaryDark.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0.0)]),
        ),
      ),
    );
  }
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.2,
      size.width,
      size.height * 0.55,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
