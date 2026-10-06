import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Settings & Support grouped list card matching the reference design:
/// - Terms & Conditions
/// - Privacy Policy
/// - Rate Us
/// - Share App
/// - Help & Support
class ProfileSettingsSupportWidget extends StatelessWidget {
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onRateUsTap;
  final VoidCallback? onShareAppTap;
  final VoidCallback? onHelpSupportTap;

  const ProfileSettingsSupportWidget({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onRateUsTap,
    this.onShareAppTap,
    this.onHelpSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Settings & Support',
          style: textTheme.titleMedium?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w800,
            fontSize: 16.5.sp,
          ),
        ),
        12.hS,

        // Grouped Options Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.pureWhite,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColor.profileCardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: onTermsTap,
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy Policy',
                onTap: onPrivacyTap,
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.star_outline_rounded,
                title: 'Rate Us',
                onTap: onRateUsTap,
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.share_outlined,
                title: 'Share App',
                onTap: onShareAppTap,
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.headset_mic_outlined,
                title: 'Help & Support',
                onTap: onHelpSupportTap,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColor.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? Radius.circular(20.r) : Radius.zero,
        ),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColor.deliveryButtonStart,
                size: 21.sp,
              ),
              14.wS,
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColor.charcoal,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColor.slateGrey,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 50.w, right: 16.w),
      child: const Divider(
        height: 1,
        thickness: 0.8,
        color: AppColor.profileCardBorder,
      ),
    );
  }
}
