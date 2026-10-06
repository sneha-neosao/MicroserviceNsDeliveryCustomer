import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_color.dart';

/// Top header on Home Screen displaying delivery address selector and search trigger.
class HomeHeaderWidget extends StatelessWidget {
  final DeliveryLocationModel? location;
  final VoidCallback onAddressTap;

  const HomeHeaderWidget({
    super.key,
    required this.location,
    required this.onAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = location?.title.isNotEmpty == true
        ? location!.title
        : 'Select Delivery Location';

    final address = location?.formattedAddress.isNotEmpty == true
        ? location!.formattedAddress
        : 'Tap to choose address for delivery';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Row with Brand Logo & Address Selector
            Row(
              children: [
                // Delivery Pin Icon
                GestureDetector(
                  onTap: onAddressTap,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColor.deliveryButtonStart.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColor.deliveryButtonStart,
                      size: 20.sp,
                    ),
                  ),
                ),
                10.wS,

                // Address info & Dropdown Arrow
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAddressTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: AppColor.charcoal,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            4.wS,
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColor.deliveryButtonStart,
                              size: 20.sp,
                            ),
                          ],
                        ),
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColor.slateGrey,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notifications or Profile Quick Icon
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColor.deliveryInputBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.deliveryInputBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColor.charcoal,
                    size: 19.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
