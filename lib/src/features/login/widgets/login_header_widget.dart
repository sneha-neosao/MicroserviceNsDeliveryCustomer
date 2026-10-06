import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Header widget displaying the NS Delivery app logo, tagline, welcome text, and subtitle.
class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  static const String _logoAsset = 'assets/images/app_logo.png';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App Logo
        Image.asset(
          _logoAsset,
          width: 140.w,
          fit: BoxFit.contain,
        ),
        8.hS,

        // Fresh • Groceries • Food
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'fresh'.tr(),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.deliveryTaglineText,
              ),
            ),
            8.wS,
            Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColor.deliveryTaglineDot,
                shape: BoxShape.circle,
              ),
            ),
            8.wS,
            Text(
              'groceries'.tr(),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.deliveryTaglineText,
              ),
            ),
            8.wS,
            Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColor.deliveryTaglineDot,
                shape: BoxShape.circle,
              ),
            ),
            8.wS,
            Text(
              'food'.tr(),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.deliveryTaglineText,
              ),
            ),
          ],
        ),
        6.hS,

        // ── All in One Place ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32.w,
              height: 1.h,
              color: AppColor.deliveryTaglineDivider,
            ),
            10.wS,
            Text(
              'all_in_one_place'.tr(),
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.deliveryTaglineText,
              ),
            ),
            10.wS,
            Container(
              width: 32.w,
              height: 1.h,
              color: AppColor.deliveryTaglineDivider,
            ),
          ],
        ),
        26.hS,

        // Welcome Back!
        Text(
          'welcome_back'.tr(),
          style: textTheme.displayMedium?.copyWith(
            fontSize: 25.sp,
            fontWeight: FontWeight.w800,
            color: AppColor.deliveryGreen,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        6.hS,

        // Login with your mobile number to continue
        Text(
          'login_with_mobile_subtitle'.tr(),
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w400,
            color: AppColor.deliverySubtitle,
            height: 1.35,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
