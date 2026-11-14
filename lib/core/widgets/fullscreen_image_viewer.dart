import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

import 'app_network_image.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;
  final String? subtitle;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.title,
    this.subtitle,
  });

  static void show(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    required String title,
    String? subtitle,
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.primaryDark.withOpacity(0.92),
      builder: (ctx) => FullscreenImageViewer(
        images: images,
        initialIndex: initialIndex,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validImages = widget.images
        .where((img) => img.trim().isNotEmpty && img != 'placeholder.jpg')
        .toList();
    final hasImages = validImages.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Interactive Image Area
          if (!hasImages)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 72,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Picha haipatikani kwa sasa',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.85),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: validImages.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: AppNetworkImage(
                      imageUrl: validImages[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      placeholderIcon: Icons.image_outlined,
                    ),
                  ),
                );
              },
            ),

          // Top App Bar Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Counter Badge
                  if (validImages.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${validImages.length}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Close Button
                  CircleAvatar(
                    backgroundColor: AppColors.primaryDark.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Info Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primaryDark.withOpacity(0.9),
                    AppColors.primaryDark.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.zoom_in,
                          color: AppColors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bana au vuta picha kwa vidole viwili ili kuikuza (Pinch to zoom)',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
