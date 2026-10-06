import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/extensions/integer_sizedbox_extension.dart';
import '../../core/theme/app_color.dart';
import '../../core/theme/app_font.dart';

/// Reusable unified alert dialog widget.
/// Features a primary full Gradient Button and a secondary Gradient-Border Button
/// with black text and identical button sizing.
class AppAlertDialogWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool showCloseIcon;

  const AppAlertDialogWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.icon,
    this.iconBgColor,
    this.iconColor,
    required this.onConfirm,
    this.onCancel,
    this.isLoading = false,
    this.showCloseIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Badge
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: iconBgColor ??
                        AppColor.buttonGradientStart.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColor.buttonGradientStart,
                    size: 28.sp,
                  ),
                ),
                16.hS,

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppFont.bold.copyWith(
                    fontSize: 18.sp,
                    color: AppColor.black,
                  ),
                ),
                8.hS,

                // Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppFont.normal.copyWith(
                    fontSize: 13.sp,
                    color: AppColor.textSecondary,
                    height: 1.4,
                  ),
                ),
                28.hS,

                // Equal-Sized Action Buttons Row
                Row(
                  children: [
                    // Secondary Button: Gradient Border, White Interior, Black Text
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23.r),
                            gradient: const LinearGradient(
                              colors: [
                                AppColor.buttonGradientStart,
                                AppColor.buttonGradientEnd,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.pureWhite,
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            child: Material(
                              color: AppColor.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22.r),
                                onTap: onCancel ?? () => Navigator.pop(context),
                                child: Center(
                                  child: Text(
                                    cancelText,
                                    style: AppFont.semiBold.copyWith(
                                      fontSize: 13.sp,
                                      color: AppColor.black,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    12.wS,

                    // Primary Button: Full Gradient Background, White Text
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23.r),
                            gradient: const LinearGradient(
                              colors: [
                                AppColor.buttonGradientStart,
                                AppColor.buttonGradientEnd,
                              ],
                            ),
                          ),
                          child: Material(
                            color: AppColor.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(23.r),
                              onTap: isLoading ? null : onConfirm,
                              child: Center(
                                child: isLoading
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColor.pureWhite,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        confirmText,
                                        style: AppFont.semiBold.copyWith(
                                          fontSize: 13.sp,
                                          color: AppColor.pureWhite,
                                          height: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close Icon at top-right (Optional)
          if (showCloseIcon)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: AppColor.slateGrey.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
