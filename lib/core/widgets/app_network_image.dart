import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      return _buildPlaceholder(clipRadius);
    }

    // 1. Base64 Data URI
    if (cleanUrl.startsWith('data:image')) {
      try {
        final commaIdx = cleanUrl.indexOf(',');
        final base64Str = commaIdx != -1 ? cleanUrl.substring(commaIdx + 1) : cleanUrl;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: clipRadius,
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildPlaceholder(clipRadius),
          ),
        );
      } catch (_) {
        return _buildPlaceholder(clipRadius);
      }
    }

    // 2. Local File Image (Camera, Gallery, File Path)
    if (!kIsWeb && (cleanUrl.startsWith('/') || cleanUrl.startsWith('file://'))) {
      try {
        final filePath = cleanUrl.replaceFirst('file://', '');
        final file = File(filePath);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: clipRadius,
            child: Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _buildPlaceholder(clipRadius),
            ),
          );
        }
      } catch (_) {
        // Fall back to placeholder if file access fails
      }
    }

    // 3. Network URL (http/https)
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Image.network(
          cleanUrl,
          width: width,
          height: height,
          fit: fit,
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
            return _buildPlaceholder(clipRadius);
          },
        ),
      );
    }

    // 4. Default placeholder for placeholders like 'placeholder.jpg' or assets
    return _buildPlaceholder(clipRadius);
  }

  Widget _buildPlaceholder(BorderRadius clipRadius) {
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
}
