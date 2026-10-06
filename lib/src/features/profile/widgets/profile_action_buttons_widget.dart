import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Bottom action buttons matching the design:
/// - [Logout] with orange outline
/// - [Delete Account] with red outline and subtle red tint
class ProfileActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onLogoutTap;
  final VoidCallback? onDeleteAccountTap;

  const ProfileActionButtonsWidget({
    super.key,
    this.onLogoutTap,
    this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Logout Button
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColor.pureWhite,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColor.deliveryButtonStart,
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.deliveryButtonStart.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: AppColor.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: onLogoutTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColor.deliveryButtonStart,
                      size: 18.sp,
                    ),
                    8.wS,
                    Text(
                      'Logout',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColor.deliveryButtonStart,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        12.wS,

        // Delete Account Button
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColor.bright_red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColor.bright_red.withValues(alpha: 0.3),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.bright_red.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: AppColor.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: onDeleteAccountTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: AppColor.bright_red,
                      size: 19.sp,
                    ),
                    8.wS,
                    Text(
                      'Delete Account',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColor.bright_red,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
