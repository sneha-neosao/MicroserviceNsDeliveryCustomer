import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/address_list_response.dart';

/// Interactive card widget presenting a saved address with:
/// - Label tag (Home, Work, Other)
/// - Default status chip
/// - Recipient contact info
/// - Full address with landmark and city
/// - Selection state indicator
class AddressCardWidget extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AddressCardWidget({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  IconData _getLabelIcon(String label) {
    final lower = label.toLowerCase().trim();
    if (lower.contains('home')) return Icons.home_rounded;
    if (lower.contains('work') || lower.contains('office')) {
      return Icons.business_rounded;
    }
    return Icons.place_rounded;
  }

  String _formatLabel(String label) {
    if (label.isEmpty || label.toLowerCase() == 'string') {
      return 'Other';
    }
    return label[0].toUpperCase() + label.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayLabel = _formatLabel(address.label);
    final icon = _getLabelIcon(address.label);

    final borderColor = isSelected
        ? AppColor.primary
        : AppColor.deliveryInputBorder;

    final bgColor = isSelected
        ? AppColor.deliveryInputBg
        : AppColor.pureWhite;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColor.primary.withValues(alpha: 0.15)
                : AppColor.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Tag Icon + Label + Badges + Selection indicator
                Row(
                  children: [
                    // Icon inside rounded container
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primary.withValues(alpha: 0.12)
                            : AppColor.deliveryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColor.primary
                            : AppColor.deliveryGreen,
                        size: 17.sp,
                      ),
                    ),
                    10.wS,

                    // Label Title
                    Text(
                      displayLabel,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColor.charcoal,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.wS,

                    // Default Address Badge
                    if (address.isDefault) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.deliveryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColor.deliveryGreen,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Edit Icon Button
                    if (onEdit != null) ...[
                      Material(
                        color: AppColor.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: onEdit,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColor.deliveryInputBg,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColor.deliveryInputBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: AppColor.deliveryButtonStart,
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      6.wS,
                    ],

                    // Delete Icon Button
                    if (onDelete != null) ...[
                      Material(
                        color: AppColor.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: onDelete,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColor.bright_red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColor.bright_red.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: AppColor.bright_red,
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      8.wS,
                    ],

                    // Radio Selection Indicator
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primary
                              : AppColor.deliveryInputBorder,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppColor.primary
                            : AppColor.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColor.pureWhite,
                                size: 14.sp,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                12.hS,

                // Recipient Name & Phone Row
                if (address.deliveryName.isNotEmpty ||
                    address.deliveryPhone.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: AppColor.slateGrey,
                        size: 15.sp,
                      ),
                      6.wS,
                      Expanded(
                        child: Text(
                          [
                            if (address.deliveryName.isNotEmpty)
                              address.deliveryName,
                            if (address.deliveryPhone.isNotEmpty)
                              address.deliveryPhone,
                          ].join(' • '),
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColor.charcoal,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.hS,
                ],

                // Full Address description with multi-line safety
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: AppColor.deliveryInputHint,
                        size: 15.sp,
                      ),
                    ),
                    6.wS,
                    Expanded(
                      child: Text(
                        address.fullAddress.isNotEmpty
                            ? address.fullAddress
                            : '${address.addressLine}, ${address.city} - ${address.pincode}',
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColor.slateGrey,
                          fontSize: 12.sp,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
