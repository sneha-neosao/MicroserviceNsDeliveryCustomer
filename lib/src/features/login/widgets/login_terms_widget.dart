import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Terms and conditions statement displayed below the action button.
class LoginTermsWidget extends StatelessWidget {
  final VoidCallback? onTermsTap;

  const LoginTermsWidget({
    super.key,
    this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'by_continuing_agree'.tr(),
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: AppColor.deliveryTermsText,
          ),
          textAlign: TextAlign.center,
        ),
        2.hS,
        GestureDetector(
          onTap: onTermsTap,
          child: Text(
            'terms_and_conditions'.tr(),
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.deliveryTermsLink,
              decoration: TextDecoration.underline,
              decorationColor: AppColor.deliveryTermsLink,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
