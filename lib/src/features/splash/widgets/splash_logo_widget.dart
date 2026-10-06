import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Centered brand logo animation sequence for splash screen:
/// 1. White circle with m_icon_logo pops in at center.
/// 2. Slides smoothly to the left.
/// 3. White circle expands to cover full screen (turning background pure white).
/// 4. As screen turns white and maha_charger_icon_logo slides in, splash_bg.png appears
///    blurry at the background and smoothly clarifies.
/// 5. Luminous angled shimmer sweeps across both brand logos.
class SplashLogoWidget extends StatefulWidget {
  const SplashLogoWidget({super.key});

  @override
  State<SplashLogoWidget> createState() => _SplashLogoWidgetState();
}

class _SplashLogoWidgetState extends State<SplashLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _entranceScale;
  late final Animation<double> _slideProgress;
  late final Animation<double> _expandScale;
  late final Animation<double> _shadowOpacity;

  late final Animation<double> _bgOpacity;
  late final Animation<double> _bgBlur;

  late final Animation<double> _mahaSlideProgress;
  late final Animation<double> _mahaOpacity;

  late final Animation<double> _shimmerProgress;

  static const String _mLogoAsset = 'assets/icons/m_icon_logo.png';
  static const String _mahaChargerLogoAsset =
      'assets/icons/maha_charger_icon_logo.png';
  static const String _splashBgAsset = 'assets/images/splash_bg.png';

  bool _systemUiSwitched = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );

    // 1. Initial scale entrance: 0 to 620ms (0.00 to 0.12)
    _entranceScale = Tween<double>(
      begin: 0.15,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.12, curve: Curves.easeOutBack),
      ),
    );

    // 2. Slow, graceful slide left: 935ms to 2290ms (0.18 to 0.44) -> ~1350ms duration
    _slideProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.44, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Slow, gradual circle expansion: 2500ms to 3950ms (0.48 to 0.76) -> ~1450ms duration
    _expandScale = Tween<double>(
      begin: 1.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.76, curve: Curves.easeInOutCubic),
      ),
    );

    // Shadow fades out during expansion
    _shadowOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.60, curve: Curves.easeOut),
      ),
    );

    // 4. Background image (splash_bg.png) fades in and unblurs smoothly: 3850ms to 4580ms (0.74 to 0.88)
    _bgOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.74, 0.86, curve: Curves.easeIn),
      ),
    );

    _bgBlur = Tween<double>(
      begin: 24.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.74, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    // 5. maha_charger_icon_logo slides in from right: 3950ms to 4580ms (0.76 to 0.88)
    _mahaSlideProgress = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    _mahaOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.84, curve: Curves.easeIn),
      ),
    );

    // 6. Shimmer sweeps across both logos: 4580ms to 5100ms (0.88 to 0.98)
    _shimmerProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 0.98, curve: Curves.easeInOutSine),
      ),
    );

    _controller.addListener(_handleAnimationProgress);
    _controller.forward();
  }

  void _handleAnimationProgress() {
    // Switch status bar icons to dark once screen turns solid white
    if (!_systemUiSwitched && _controller.value >= 0.74) {
      _systemUiSwitched = true;
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: AppColor.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColor.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimationProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Both icons balanced across the horizontal center:
    // Left icon centered at -58.w, right icon centered at +52.w (gap ~8.w, centered together)
    final slideOffset = -58.w;
    final mahaTargetOffset = 52.w;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentMOffset = slideOffset * _slideProgress.value;
        final currentMahaOffset =
            mahaTargetOffset + (160.w * _mahaSlideProgress.value);
        final shimmerVal = _shimmerProgress.value;
        final showShimmer = shimmerVal > 0.0 && shimmerVal < 1.0;
        final bgOpacityVal = _bgOpacity.value.clamp(0.0, 1.0);
        final currentBlur = _bgBlur.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Expanding white circle (becomes full white screen background)
            Center(
              child: Transform.translate(
                offset: Offset(currentMOffset, 0),
                child: Transform.scale(
                  scale: _expandScale.value * _entranceScale.value,
                  child: Container(
                    width: 124.w,
                    height: 124.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.pureWhite,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(
                            alpha:
                                (0.20 * _shadowOpacity.value).clamp(0.0, 1.0),
                          ),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. splash_bg.png on white background (first blurry, then appears smoothly)
            if (_controller.value >= 0.74 && bgOpacityVal > 0.0)
              Positioned.fill(
                child: ClipRect(
                  child: Opacity(
                    opacity: bgOpacityVal,
                    child: currentBlur > 0.05
                        ? ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(
                              sigmaX: currentBlur,
                              sigmaY: currentBlur,
                              tileMode: TileMode.clamp,
                            ),
                            child: Image.asset(
                              _splashBgAsset,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          )
                        : Image.asset(
                            _splashBgAsset,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                  ),
                ),
              ),

            // 3. Combined brand logos at screen center
            Center(
              child: SizedBox(
                width: 280.w,
                height: 124.w,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // [A] m_icon_logo (left icon image)
                    Transform.translate(
                      offset: Offset(currentMOffset, 0),
                      child: Transform.scale(
                        scale: _entranceScale.value,
                        child: SizedBox(
                          width: 86.w,
                          height: 86.w,
                          child: Center(
                            child: Image.asset(
                              _mLogoAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // [B] maha_charger_icon_logo (right icon image with height 70.h)
                    if (_controller.value >= 0.74)
                      Transform.translate(
                        offset: Offset(currentMahaOffset, 0),
                        child: Opacity(
                          opacity: _mahaOpacity.value.clamp(0.0, 1.0),
                          child: SizedBox(
                            width: 118.w,
                            height: 70.h,
                            child: Center(
                              child: Image.asset(
                                _mahaChargerLogoAsset,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // [C] Luminous angled shimmer light-sweep across BOTH logos
                    if (showShimmer)
                      Positioned.fill(
                        child: ClipRect(
                          child: Transform.translate(
                            offset: Offset(
                              -180.w + (360.w * shimmerVal),
                              0,
                            ),
                            child: Transform.rotate(
                              angle: 0.35, // ~20 degree angle
                              child: Center(
                                child: Container(
                                  width: 65.w,
                                  height: 240.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.pureWhite
                                            .withValues(alpha: 0.0),
                                        AppColor.pureWhite
                                            .withValues(alpha: 0.45),
                                        AppColor.pureWhite
                                            .withValues(alpha: 0.95),
                                        AppColor.pureWhite
                                            .withValues(alpha: 0.45),
                                        AppColor.pureWhite
                                            .withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
