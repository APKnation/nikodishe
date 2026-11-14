import 'package:flutter/material.dart';

/// Official Kodisha logo, used everywhere the brand mark appears.
///
/// The source image is a wide lockup ("APPY MUKODISHA" + tagline), so the
/// widget keeps its aspect ratio and can be scaled responsively by callers.
class AppLogo extends StatelessWidget {
  /// Fixed width. When null, width is derived from [height].
  final double? width;

  /// Fixed height. Used with [width] to preserve the lockup proportions.
  final double height;

  /// Draws a white rounded plate behind the image so it reads well on orange.
  final bool plate;

  /// Corner radius of the plate.
  final double radius;

  final BoxFit fit;

  /// Backing color for the plate. Defaults to the logo artwork's own
  /// cream background so the image blends seamlessly instead of showing
  /// a visible rectangle on pure white screens.
  final Color plateColor;

  const AppLogo({
    super.key,
    this.width,
    this.height = 64,
    this.plate = true,
    this.radius = 14,
    this.fit = BoxFit.contain,
    this.plateColor = const Color(0xFFFCFBF0),
  });

  /// Path of the asset registered in pubspec.yaml.
  static const String asset = 'assets/images/kukodisha.jpeg';

  /// Logo with a transparent background — used for overlays / watermarks
  /// on colored surfaces (e.g. the orange auth header).
  static const String transparentAsset = 'assets/images/kukodisha_transparent.png';

  /// Natural aspect ratio of the artwork (width / height).
  static const double aspectRatio = 1408 / 768;

  /// Convenience size that respects a bounded area.
  ///
  /// [maxWidth] is scaled by [fraction] and clamped between [minWidth] and
  /// [maxWidth] so the logo stays readable from small phones to tablets.
  static Size responsiveSize(
    double availableWidth, {
    double fraction = 0.66,
    double minWidth = 180,
    double maxWidth = 280,
  }) {
    final w = (availableWidth * fraction).clamp(minWidth, maxWidth).toDouble();
    return Size(w, w / aspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    final double w = width ?? height * aspectRatio;

    final image = Image.asset(
      asset,
      width: w,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
    );

    if (!plate) return image;

    return Container(
      width: w,
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: plateColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: image,
    );
  }
}
