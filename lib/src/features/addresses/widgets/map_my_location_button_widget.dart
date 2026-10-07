import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Floating circular button to center map on user's current GPS location.
class MapMyLocationButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const MapMyLocationButtonWidget({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.deliveryButtonStart,
                    ),
                  )
                : Icon(
                    Icons.my_location_rounded,
                    color: AppColor.deliveryButtonStart,
                    size: 22.sp,
                  ),
          ),
        ),
      ),
    );
  }
}
