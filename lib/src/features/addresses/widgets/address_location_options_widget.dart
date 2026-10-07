import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Row of 2 compact quick location options:
/// 1. [Use Current Location] (GPS)
/// 2. [Add New Location] (Map selector)
/// Compact horizontal layout: Icon followed directly by text without arrow.
class AddressLocationOptionsWidget extends StatelessWidget {
  final bool isLoadingCurrentLocation;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onAddNewLocation;

  const AddressLocationOptionsWidget({
    super.key,
    required this.isLoadingCurrentLocation,
    required this.onUseCurrentLocation,
    required this.onAddNewLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Option 1: Use Current Location
          Expanded(
            child: _LocationOptionTile(
              icon: Icons.my_location_rounded,
              iconColor: AppColor.deliveryGreen,
              iconBgColor: AppColor.deliveryGreen.withValues(alpha: 0.1),
              title: 'Current Location',
              subtitle: 'Using GPS',
              isLoading: isLoadingCurrentLocation,
              onTap: onUseCurrentLocation,
            ),
          ),
          10.wS,

          // Option 2: Add New Location
          Expanded(
            child: _LocationOptionTile(
              icon: Icons.add_location_alt_outlined,
              iconColor: AppColor.deliveryButtonStart,
              iconBgColor: AppColor.deliveryButtonStart.withValues(alpha: 0.1),
              title: 'Add New',
              subtitle: 'Select on Map',
              isLoading: false,
              onTap: onAddNewLocation,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _LocationOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColor.deliveryInputBorder,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              children: [
                // Circular icon or loading indicator
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: iconColor,
                            ),
                          )
                        : Icon(
                            icon,
                            color: iconColor,
                            size: 18.sp,
                          ),
                  ),
                ),
                8.wS,

                // Title and subtitle in front of the icon
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColor.charcoal,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      1.hS,
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColor.slateGrey,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
