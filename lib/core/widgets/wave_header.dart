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
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    // Blue fills all the way down to the corners; the bottom edge is a
    // gentle wave so the white form area never climbs up into the header.
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 34,
      size.width * 0.50,
      size.height - 14,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height + 6,
      0,
      size.height - 26,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
