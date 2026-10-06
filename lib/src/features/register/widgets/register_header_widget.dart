import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Header widget displaying the NS Delivery app logo, registration title, and subtitle.
class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

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
        18.hS,

        // Complete Registration Heading
        Text(
          'Register',
          style: textTheme.displayMedium?.copyWith(
            fontSize: 25.sp,
            fontWeight: FontWeight.w800,
            color: AppColor.deliveryGreen,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        6.hS,

        // Subtitle
        Text(
          'Please complete your profile to continue',
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
