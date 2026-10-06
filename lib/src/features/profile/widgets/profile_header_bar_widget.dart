import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

class ProfileHeaderBarWidget extends StatelessWidget {
  const ProfileHeaderBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: textTheme.headlineSmall?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w800,
            fontSize: 22.sp,
          ),
        ),
        3.hS,
        Text(
          'Manage your account and preferences',
          style: textTheme.bodySmall?.copyWith(
            color: AppColor.slateGrey,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
