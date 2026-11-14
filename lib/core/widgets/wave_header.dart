import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A soft wavy header inspired by modern auth designs.
/// Used by the login / register screens.
class WaveHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final List<Color> colors;

  const WaveHeader({
    super.key,
    required this.child,
    this.height = 250,
    this.colors = const [AppColors.primary, AppColors.primaryDark],
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 56);
    // Left valley → center peak
    path.quadraticBezierTo(
      size.width * 0.24,
      size.height + 6,
      size.width * 0.5,
      size.height - 44,
    );
    // Center peak → right valley
    path.quadraticBezierTo(
      size.width * 0.76,
      size.height - 94,
      size.width,
      size.height - 34,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
