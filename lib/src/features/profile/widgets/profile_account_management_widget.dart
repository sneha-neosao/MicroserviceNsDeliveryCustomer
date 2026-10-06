import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Account Management section matching Settings & Support card styling:
/// - Grouped card with Logout and Delete Account options
class ProfileAccountManagementWidget extends StatelessWidget {
  final VoidCallback? onLogoutTap;
  final VoidCallback? onDeleteAccountTap;

  const ProfileAccountManagementWidget({
    super.key,
    this.onLogoutTap,
    this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Account Management',
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
              _AccountTile(
                icon: Icons.logout_rounded,
                iconColor: AppColor.deliveryButtonStart,
                title: 'Logout',
                titleColor: AppColor.charcoal,
                onTap: onLogoutTap,
              ),
              const _TileDivider(),
              _AccountTile(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColor.bright_red,
                title: 'Delete Account',
                titleColor: AppColor.bright_red,
                onTap: onDeleteAccountTap,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final VoidCallback? onTap;
  final bool isLast;

  const _AccountTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
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
          top: isLast ? Radius.zero : Radius.circular(20.r),
        ),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 21.sp,
              ),
              14.wS,
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: titleColor,
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
