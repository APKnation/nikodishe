import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Solid decorative wave sitting at the bottom of a screen.
/// Mirrors the header wave used on auth screens.
class BottomWave extends StatelessWidget {
  final double height;
  final Color color;

  const BottomWave({
    super.key,
    this.height = 80,
    this.color = AppColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: color,
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.62);
    path.quadraticBezierTo(
      size.width * 0.24,
      size.height * 0.10,
      size.width * 0.5,
      size.height * 0.52,
    );
    path.quadraticBezierTo(
      size.width * 0.76,
      size.height * 0.94,
      size.width,
      size.height * 0.42,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
