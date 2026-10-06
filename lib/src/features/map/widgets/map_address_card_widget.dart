import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_color.dart';

/// Bottom card on map screen displaying selected address details and "Confirm Location" button.
class MapAddressCardWidget extends StatelessWidget {
  final DeliveryLocationModel? location;
  final bool isLoading;
  final VoidCallback onConfirm;

  const MapAddressCardWidget({
    super.key,
    required this.location,
    this.isLoading = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = location?.title.isNotEmpty == true
        ? location!.title
        : 'Detecting location...';

    final address = location?.formattedAddress.isNotEmpty == true
        ? location!.formattedAddress
        : 'Move map pin to locate your exact delivery doorstep';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.gray.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            14.hS,

            // Header Row: Delivery Location Label
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColor.deliveryButtonStart.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColor.deliveryButtonStart,
                    size: 18.sp,
                  ),
                ),
                10.wS,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Delivery Location',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColor.slateGrey,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      2.hS,
                      if (isLoading)
                        Row(
                          children: [
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: AppColor.deliveryButtonStart,
                              ),
                            ),
                            8.wS,
                            Text(
                              'Fetching address details...',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColor.slateGrey,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColor.charcoal,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            8.hS,

            // Full address string
            Text(
              address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColor.textSecondary,
                fontSize: 12.5.sp,
                height: 1.35,
              ),
            ),
            18.hS,

            // Confirm Location Gradient Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.r),
                  gradient: const LinearGradient(
                    colors: [
                      AppColor.deliveryButtonStart,
                      AppColor.deliveryButtonEnd,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.deliveryButtonStart.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColor.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28.r),
                    onTap: isLoading || location == null ? null : onConfirm,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm Location',
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.pureWhite,
                              letterSpacing: 0.3,
                            ),
                          ),
                          8.wS,
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColor.pureWhite,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
