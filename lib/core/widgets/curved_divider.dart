import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A soft curved separator that sits on top of the white form area and
/// overlaps the bottom of the logo header, so the two sections are divided
/// by a design curve instead of a flat straight line.
class CurvedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double curveDepth;

  const CurvedDivider({
    super.key,
    this.height = 34,
    this.color = AppColors.white,
    this.curveDepth = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurveClipper(curveDepth),
      child: Container(
        height: height,
        width: double.infinity,
        color: color,
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  final double depth;

  const _CurveClipper(this.depth);

  @override
  Path getClip(Size size) {
    final path = Path();
    final crest = size.height * (1 - depth.clamp(0.0, 1.0));
    path.moveTo(0, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.5,
      crest,
      size.width,
      size.height * 0.42,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CurveClipper oldClipper) =>
      oldClipper.depth != depth;
}
