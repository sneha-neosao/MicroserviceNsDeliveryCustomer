import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Custom dialog for confirming user logout.
class ProfileLogoutDialog extends StatelessWidget {
  final VoidCallback onConfirmLogout;

  const ProfileLogoutDialog({
    super.key,
    required this.onConfirmLogout,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirmLogout,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColor.black.withValues(alpha: 0.5),
      builder: (_) => ProfileLogoutDialog(
        onConfirmLogout: onConfirmLogout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColor.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 18.h),
        decoration: BoxDecoration(
          color: AppColor.pureWhite,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppColor.deliveryButtonStart.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColor.deliveryButtonStart,
                  size: 26.sp,
                ),
              ),
            ),
            14.hS,
            Text(
              'Logout Confirmation',
              style: textTheme.titleMedium?.copyWith(
                color: AppColor.charcoal,
                fontWeight: FontWeight.w800,
                fontSize: 17.sp,
              ),
            ),
            6.hS,
            Text(
              'Are you sure you want to log out from your account?',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColor.slateGrey,
                fontSize: 12.5.sp,
                height: 1.35,
              ),
            ),
            20.hS,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      side: const BorderSide(
                        color: AppColor.profileCardBorder,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColor.slateGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
                12.wS,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmLogout();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      backgroundColor: AppColor.deliveryButtonStart,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColor.pureWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
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
