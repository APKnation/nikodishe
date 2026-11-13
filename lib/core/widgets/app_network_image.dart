import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../network/api_config.dart';

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

    if (cleanUrl.isEmpty || cleanUrl == 'placeholder.jpg') {
      return _buildPlaceholder(clipRadius);
    }

    // Rekebisha URL za media za backend (mf. /media/listings/... au localhost/127.0.0.1)
    String targetUrl = cleanUrl;
    if (targetUrl.startsWith('/media/') || targetUrl.startsWith('/static/')) {
      targetUrl = ApiConfig.resolveMediaUrl(targetUrl);
    } else if (targetUrl.contains('127.0.0.1:8000') ||
        targetUrl.contains('localhost:8000') ||
        targetUrl.contains('10.0.2.2:8000')) {
      targetUrl = ApiConfig.resolveMediaUrl(targetUrl);
    }

    // 1. Base64 Data URI
    if (targetUrl.startsWith('data:image')) {
      try {
        final commaIdx = targetUrl.indexOf(',');
        final base64Str = commaIdx != -1 ? targetUrl.substring(commaIdx + 1) : targetUrl;
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

    // 2. Network URL (http/https) - Pakua picha kutoka mtandaoni au backend
    if (targetUrl.startsWith('http://') || targetUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Image.network(
          targetUrl,
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

    // 3. Local File Image (Camera, Gallery au Storage ya simu)
    if (!kIsWeb && (targetUrl.startsWith('/') || targetUrl.startsWith('file://'))) {
      try {
        final filePath = targetUrl.replaceFirst('file://', '');
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
        // Fall back to placeholder
      }
    }

    // 4. Fallback placeholder
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
