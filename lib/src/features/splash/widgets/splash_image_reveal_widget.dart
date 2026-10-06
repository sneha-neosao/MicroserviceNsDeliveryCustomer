import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';

/// Full-screen splash image reveal widget with:
/// 1. Smooth blur-to-clear transition (`ui.ImageFilter.blur`).
/// 2. Subtle camera focus scale and fade-in.
/// 3. Luminous angled shimmer sweep across the image once crystal clear.
class SplashImageRevealWidget extends StatefulWidget {
  const SplashImageRevealWidget({super.key});

  @override
  State<SplashImageRevealWidget> createState() => _SplashImageRevealWidgetState();
}

class _SplashImageRevealWidgetState extends State<SplashImageRevealWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _blurAnimation;
  late final Animation<double> _shimmerAnimation;

  static const String _splashImageAsset = 'assets/images/splash.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 1. Initial fade-in: 0 to 750ms (0.00 to 0.25)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.25, curve: Curves.easeIn),
      ),
    );

    // 2. Cinematic focus scale (subtle 1.05 to 1.00): 0 to 1650ms (0.00 to 0.55)
    _scaleAnimation = Tween<double>(
      begin: 1.05,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Smooth blur to crystal clear: 0 to 1650ms (0.00 to 0.55)
    _blurAnimation = Tween<double>(
      begin: 25.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.55, curve: Curves.easeInOutCubic),
      ),
    );

    // 4. Shimmer sweep once clear: 1800ms to 2760ms (0.60 to 0.92)
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.92, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentBlur = _blurAnimation.value;
        final currentScale = _scaleAnimation.value;
        final currentOpacity = _fadeAnimation.value.clamp(0.0, 1.0);
        final shimmerVal = _shimmerAnimation.value;
        final showShimmer = shimmerVal > 0.0 && shimmerVal < 1.0;

        Widget imageWidget = Image.asset(
          _splashImageAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        );

        if (currentBlur > 0.05) {
          imageWidget = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: currentBlur,
              sigmaY: currentBlur,
              tileMode: TileMode.clamp,
            ),
            child: imageWidget,
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Splash image with blur-to-clear & subtle focus scale
            Opacity(
              opacity: currentOpacity,
              child: Transform.scale(
                scale: currentScale,
                child: imageWidget,
              ),
            ),

            // 2. Luminous angled shimmer sweep across the clear image
            if (showShimmer)
              Positioned.fill(
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: screenWidth * 3,
                    maxHeight: screenHeight * 2,
                    child: Transform.translate(
                      offset: Offset(
                        (-screenWidth * 1.2) + (screenWidth * 2.6 * shimmerVal),
                        0,
                      ),
                      child: Transform.rotate(
                        angle: -0.42, // ~24 degree angle
                        child: Center(
                          child: Container(
                            width: 140,
                            height: screenHeight * 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.pureWhite.withValues(alpha: 0.0),
                                  AppColor.pureWhite.withValues(alpha: 0.12),
                                  AppColor.pureWhite.withValues(alpha: 0.45),
                                  AppColor.pureWhite.withValues(alpha: 0.75),
                                  AppColor.pureWhite.withValues(alpha: 0.45),
                                  AppColor.pureWhite.withValues(alpha: 0.12),
                                  AppColor.pureWhite.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.25, 0.42, 0.5, 0.58, 0.75, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
