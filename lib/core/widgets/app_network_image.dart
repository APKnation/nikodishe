import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final clipRadius = borderRadius ?? BorderRadius.zero;

    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Container(
          width: width,
          height: height,
          color: AppColors.primary.withOpacity(0.08),
          child: Center(
            child: Icon(placeholderIcon, color: AppColors.primary.withOpacity(0.6), size: 36),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: clipRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // NFR3 & NFR4: Cache constraints in memory for ultra-fast performance on budget devices
        cacheWidth: width != null && width!.isFinite ? (width! * 2).toInt() : 600,
        cacheHeight: height != null && height!.isFinite ? (height! * 2).toInt() : 600,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final total = loadingProgress.expectedTotalBytes;
          final loaded = loadingProgress.cumulativeBytesLoaded;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: total != null ? loaded / total : null,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: Center(
              child: Icon(placeholderIcon, color: Colors.grey.shade400, size: 32),
            ),
          );
        },
      ),
    );
  }
}

