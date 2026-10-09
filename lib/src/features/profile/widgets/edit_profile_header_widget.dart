import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Top header for EditProfileScreen with back button, title, and subtitle.
class EditProfileHeaderWidget extends StatelessWidget {
  final VoidCallback? onBack;

  const EditProfileHeaderWidget({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColor.pureWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.profileCardBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColor.charcoal,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
            14.wS,

            // Screen Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Profile',
                    softWrap: true,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColor.charcoal,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                    ),
                  ),
                  2.hS,
                  Text(
                    'Update your personal information',
                    softWrap: true,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColor.slateGrey,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
