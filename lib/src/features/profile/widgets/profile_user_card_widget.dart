import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// User profile information card matching the reference design:
/// - Avatar with orange ring border (profile image with fallback to initials)
/// - Name and phone with call icon (email omitted per design request)
/// - Circular edit button on the right
class ProfileUserCardWidget extends StatelessWidget {
  final String name;
  final String phone;
  final String? profileImage;
  final VoidCallback? onEditTap;

  const ProfileUserCardWidget({
    super.key,
    required this.name,
    required this.phone,
    this.profileImage,
    this.onEditTap,
  });

  String _getInitials(String? value) {
    if (value == null || value.trim().isEmpty) return 'U';
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildInitialsAvatar(BuildContext context, String initials) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.walletCardBg,
      ),
      child: Center(
        child: Text(
          initials,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColor.deliveryButtonStart,
            fontWeight: FontWeight.w800,
            fontSize: 22.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = name.isNotEmpty ? name : 'User';
    final displayPhone = phone.isNotEmpty ? phone : '+91 98765 43210';
    final initials = _getInitials(displayName);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.profileCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Avatar with orange ring border
          Container(
            width: 66.w,
            height: 66.w,
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.deliveryButtonStart,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profileImage != null && profileImage!.trim().isNotEmpty
                  ? Image.network(
                      profileImage!.trim(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.deliveryButtonStart,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitialsAvatar(context, initials),
                    )
                  : _buildInitialsAvatar(context, initials),
            ),
          ),
          14.wS,

          // 2. User Details Column (Only Name & Phone)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColor.charcoal,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5.sp,
                  ),
                ),
                6.hS,

                // Phone
                Row(
                  children: [
                    Icon(
                      Icons.call_outlined,
                      size: 14.sp,
                      color: AppColor.slateGrey,
                    ),
                    6.wS,
                    Expanded(
                      child: Text(
                        displayPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColor.slateGrey,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          8.wS,

          // 3. Edit Pencil Button
          GestureDetector(
            onTap: onEditTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColor.orangeTint2,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.walletCardBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColor.deliveryButtonStart,
                  size: 17.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
