import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Clean and informative empty state widget displayed when no saved addresses exist.
class AddressEmptyWidget extends StatelessWidget {
  final VoidCallback onAddNew;

  const AddressEmptyWidget({
    super.key,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative circular icon container
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: AppColor.deliveryButtonStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.location_off_rounded,
                  color: AppColor.deliveryButtonStart,
                  size: 42.sp,
                ),
              ),
            ),
            20.hS,

            // Primary Message
            Text(
              'No Saved Addresses Found',
              softWrap: true,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                color: AppColor.charcoal,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            8.hS,

            // Subtitle Description
            Text(
              'You have not added any delivery address yet. Add your home, work, or another location to get fast deliveries.',
              softWrap: true,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColor.slateGrey,
                fontSize: 12.5.sp,
                height: 1.4,
              ),
            ),
            24.hS,

            // Call to action button
            GestureDetector(
              onTap: onAddNew,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColor.deliveryButtonStart,
                      AppColor.deliveryButtonEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.deliveryButtonStart.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_location_alt_rounded,
                      color: AppColor.pureWhite,
                      size: 18.sp,
                    ),
                    8.wS,
                    Text(
                      'Add New Address',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColor.pureWhite,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
