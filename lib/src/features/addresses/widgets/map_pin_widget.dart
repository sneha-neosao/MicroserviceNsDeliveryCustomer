import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Fixed center map marker representing the targeted delivery location.
class MapPinWidget extends StatelessWidget {
  final bool isMoving;

  const MapPinWidget({
    super.key,
    this.isMoving = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 36.h), // Offset so pin tip lands on center
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Delivery Pin Head
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, isMoving ? -10 : 0, 0),
                child: Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColor.deliveryButtonStart,
                        AppColor.deliveryButtonEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.pureWhite,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.deliveryButtonStart.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColor.pureWhite,
                      size: 26.sp,
                    ),
                  ),
                ),
              ),
              // Pin Needle Pointer
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, isMoving ? -10 : 0, 0),
                child: CustomPaint(
                  size: Size(12.w, 8.h),
                  painter: _TrianglePointerPainter(),
                ),
              ),
              4.verticalSpace,
              // Drop Shadow Dot on Map
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isMoving ? 10.w : 14.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.black.withValues(alpha: isMoving ? 0.15 : 0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.deliveryButtonEnd
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
