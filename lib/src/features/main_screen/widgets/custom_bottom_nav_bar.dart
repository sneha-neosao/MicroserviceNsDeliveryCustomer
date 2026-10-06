import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

class NavItemData {
  final String icon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.label,
  });
}

/// Floating pill-shaped bottom navigation bar with a smooth circular scoop cradle
/// matching the exact round geometry of the circular floating tab,
/// a generous uniform gap between orange and white components,
/// and smooth sliding transitions.
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItemData> items = [
    NavItemData(
      icon: 'assets/icons/home_icon.png',
      label: 'home',
    ),
    NavItemData(
      icon: 'assets/icons/search_icon.png',
      label: 'search',
    ),
    NavItemData(
      icon: 'assets/icons/cart_icon.png',
      label: 'cart',
    ),
    NavItemData(
      icon: 'assets/icons/profile_icon.png',
      label: 'profile',
    ),
  ];

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  double _currentPosition = 0.0;
  int _fromIndex = 0;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentIndex.toDouble();
    _fromIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _slideAnimation = Tween<double>(
      begin: _currentPosition,
      end: _currentPosition,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animController.addListener(() {
      _currentPosition = _slideAnimation.value;
    });
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _targetIndex) {
      _fromIndex = _targetIndex;
      _targetIndex = widget.currentIndex;
      _startSlideAnimation(widget.currentIndex.toDouble(), widget.currentIndex);
    }
  }

  void _startSlideAnimation(double targetPosition, int targetIndex) {
    _fromIndex = _currentPosition.round().clamp(0, CustomBottomNavBar.items.length - 1);
    _targetIndex = targetIndex;

    _slideAnimation = Tween<double>(
      begin: _currentPosition,
      end: targetPosition,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animController.forward(from: 0.0);
  }

  void _handleTabTap(int index) {
    if (index == _targetIndex) return;
    _fromIndex = _targetIndex;
    _targetIndex = index;
    widget.onTap(index);
    _startSlideAnimation(index.toDouble(), index);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _getCenterX(double pos, double totalWidth, double hInset) {
    final usableWidth = totalWidth - (2 * hInset);
    final tabWidth = usableWidth / CustomBottomNavBar.items.length;
    return hInset + (pos + 0.5) * tabWidth;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final totalWidth = MediaQuery.of(context).size.width - 32.w;
    final hInset = 28.w;
    final barHeight = 68.h;
    final circleSize = 46.w;
    final cornerRadius = 22.r;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final pos = _animController.isAnimating
            ? _slideAnimation.value
            : _currentPosition;
        final selectedCenterX = _getCenterX(pos, totalWidth, hInset);
        final animProgress = _animController.isAnimating
            ? _animController.value
            : 1.0;

        final fromIcon = CustomBottomNavBar.items[_fromIndex].icon;
        final toIcon = CustomBottomNavBar.items[_targetIndex].icon;

        return SizedBox(
          width: totalWidth,
          height: barHeight + 28.h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Smooth Circular-Scooped Gradient Background Bar
              // Slides smoothly in perfect lockstep with the white circle
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: CustomPaint(
                  size: Size(totalWidth, barHeight),
                  painter: _CircularScoopNavBarPainter(
                    centerX: selectedCenterX,
                    cornerRadius: cornerRadius,
                  ),
                ),
              ),

              // 2. Tab Items (Icons and Labels)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hInset),
                  child: Row(
                    children: List.generate(CustomBottomNavBar.items.length, (index) {
                      final item = CustomBottomNavBar.items[index];

                      // Smooth crossfade logic per tab without intermediate flicker:
                      double activeFactor = 0.0;
                      double iconOpacity = 1.0;

                      if (_fromIndex == _targetIndex) {
                        if (index == _targetIndex) {
                          activeFactor = 1.0;
                          iconOpacity = 0.0;
                        }
                      } else {
                        if (index == _targetIndex) {
                          activeFactor = animProgress;
                          iconOpacity = (1.0 - animProgress).clamp(0.0, 1.0);
                        } else if (index == _fromIndex) {
                          activeFactor = (1.0 - animProgress).clamp(0.0, 1.0);
                          iconOpacity = animProgress;
                        } else {
                          // Unaffected / intermediate tab remains steady
                          activeFactor = 0.0;
                          iconOpacity = 1.0;
                        }
                      }

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _handleTabTap(index),
                          child: Container(
                            height: barHeight,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Unselected icon fades out when active since floating circle displays it,
                                // but retains exact 20.h space so label position never shifts
                                Opacity(
                                  opacity: iconOpacity,
                                  child: Image.asset(
                                    item.icon,
                                    width: 20.w,
                                    height: 20.h,
                                    fit: BoxFit.contain,
                                    color: AppColor.pureWhite,
                                  ),
                                ),
                                3.hS,
                                // Label remains at the exact same vertical baseline for selected & unselected options
                                Text(
                                  item.label.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColor.pureWhite.withValues(
                                      alpha: 0.85 + (0.15 * activeFactor),
                                    ),
                                    fontSize: 10.5.sp,
                                    fontWeight: activeFactor > 0.5
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // 3. Elevated Floating White Circle that glides smoothly across
              Positioned(
                left: selectedCenterX - (circleSize / 2),
                bottom: barHeight - (circleSize / 2) + 9.h,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleTabTap(_targetIndex),
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: AppColor.pureWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.deliveryButtonStart.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_fromIndex != _targetIndex && animProgress < 1.0)
                            Opacity(
                              opacity: (1.0 - animProgress).clamp(0.0, 1.0),
                              child: Image.asset(
                                fromIcon,
                                width: 22.w,
                                height: 22.h,
                                fit: BoxFit.contain,
                                color: AppColor.deliveryButtonStart,
                              ),
                            ),
                          Opacity(
                            opacity: _fromIndex == _targetIndex ? 1.0 : animProgress.clamp(0.0, 1.0),
                            child: Image.asset(
                              toIcon,
                              width: 22.w,
                              height: 22.h,
                              fit: BoxFit.contain,
                              color: AppColor.deliveryButtonStart,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter rendering the pure circular scooped cradle matching the circular tab
/// with exact C1 tangent-continuity on both shoulders to eliminate any kinks or sharp transitions.
class _CircularScoopNavBarPainter extends CustomPainter {
  final double centerX;
  final double cornerRadius;

  _CircularScoopNavBarPainter({
    required this.centerX,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColor.deliveryButtonStart,
          AppColor.deliveryButtonEnd,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path();
    final r = cornerRadius;
    final cx = centerX;

    // Geometric parameters:
    // White circle radius is 23.w (46.w diameter)
    // Gap between white circle and orange scoop is 7.w
    // Concentric scoop circular radius:
    final circleRadius = 23.0.w;
    final gap = 7.0.w;
    final rScoop = circleRadius + gap; // 30.0.w

    // Circle center Y in bar coordinates (where top edge of bar is y = 0):
    // Circle bottom sits at y = 14.0.h, center is at y = -9.0.h
    final circleCenterY = -9.0.h;

    // Entry angle for the circular arc scoop: 56 degrees
    const thetaDeg = 56.0;
    const thetaRad = thetaDeg * math.pi / 180.0;
    final sinTheta = math.sin(thetaRad);
    final cosTheta = math.cos(thetaRad);

    final x0 = rScoop * sinTheta; // approx 24.9.w
    final y0 = circleCenterY + rScoop * cosTheta; // approx 7.8.h

    // Shoulder transition to horizontal bar line at y = 0
    final sW = 38.0.w; // Scoop total half-width
    final k1 = 5.5.w;  // Cubic control handle along circular arc tangent
    final k2 = 6.0.w;  // Cubic control handle along horizontal top line

    // Start at top-left corner
    path.moveTo(r, 0);

    final scoopStart = cx - sW;
    final scoopEnd = cx + sW;

    if (scoopStart > r) {
      path.lineTo(scoopStart, 0);
    } else {
      path.lineTo(r, 0);
    }

    // 1. Left shoulder: smooth cubic ease-in with exact C1 tangent continuity
    // Tangent at (cx - sW, 0) is purely horizontal (1, 0)
    // Tangent at (cx - x0, y0) matches the circular arc tangent (cosTheta, sinTheta)
    path.cubicTo(
      cx - sW + k2,
      0,
      cx - x0 - (k1 * cosTheta),
      y0 - (k1 * sinTheta),
      cx - x0,
      y0,
    );

    // 2. Pure circular concentric scoop cradle matching the white circular tab
    path.arcToPoint(
      Offset(cx + x0, y0),
      radius: Radius.circular(rScoop),
      clockwise: false,
    );

    // 3. Right shoulder: smooth cubic ease-out with exact C1 tangent continuity
    // Tangent at (cx + x0, y0) matches the circular arc tangent (cosTheta, -sinTheta)
    // Tangent at (cx + sW, 0) is purely horizontal (1, 0)
    path.cubicTo(
      cx + x0 + (k1 * cosTheta),
      y0 - (k1 * sinTheta),
      cx + sW - k2,
      0,
      scoopEnd < size.width - r ? scoopEnd : size.width - r,
      0,
    );

    // Flat line to top-right corner
    path.lineTo(size.width - r, 0);

    // Top-right corner
    path.arcToPoint(
      Offset(size.width, r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Right vertical edge
    path.lineTo(size.width, size.height - r);

    // Bottom-right corner
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Bottom horizontal edge
    path.lineTo(r, size.height);

    // Bottom-left corner
    path.arcToPoint(
      Offset(0, size.height - r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Left vertical edge
    path.lineTo(0, r);

    // Top-left corner
    path.arcToPoint(
      Offset(r, 0),
      radius: Radius.circular(r),
      clockwise: true,
    );

    path.close();

    // Soft drop shadow
    canvas.drawShadow(
      path,
      AppColor.deliveryButtonStart.withValues(alpha: 0.35),
      12.0,
      false,
    );

    // Fill with orange gradient
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CircularScoopNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
