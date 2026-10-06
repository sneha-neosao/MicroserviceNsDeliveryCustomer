import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Top curved header widget covering 25% of the screen with an orange gradient,
/// displaying:
/// - "Profile" title at the top center
/// - Circular white avatar with initials in orange
/// - Name with edit icon, mobile number, and email (if exists) in a column to the right
class ProfileHeaderCurvedWidget extends StatelessWidget {
  final double height;
  final String name;
  final String mobile;
  final String? email;
  final VoidCallback? onEdit;

  const ProfileHeaderCurvedWidget({
    super.key,
    required this.height,
    required this.name,
    required this.mobile,
    this.email,
    this.onEdit,
  });

  String _getInitials(String? value) {
    if (value == null || value.trim().isEmpty) return 'U';
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initials = _getInitials(name);
    final hasEmail = email != null && email!.trim().isNotEmpty;

    return ClipPath(
      clipper: _ProfileHeaderClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.deliveryButtonStart,
              AppColor.deliveryButtonEnd,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                6.hS,
                // 1. Profile Title at top center
                Center(
                  child: Text(
                    'profile'.tr(),
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColor.pureWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                14.hS,

                // 2. Profile Details Row (Avatar on left, Column on right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // White circle with orange initials
                    Container(
                      width: 58.w,
                      height: 58.w,
                      decoration: BoxDecoration(
                        color: AppColor.pureWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColor.deliveryButtonStart,
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    14.wS,

                    // Name + Edit Icon, Mobile, and optional Email in column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name with edit icon at right side
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  name.isNotEmpty ? name : 'User',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColor.pureWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              8.wS,
                              GestureDetector(
                                onTap: onEdit,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: AppColor.pureWhite.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: AppColor.pureWhite,
                                    size: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          3.hS,

                          // Mobile Number
                          if (mobile.isNotEmpty)
                            Text(
                              mobile,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColor.pureWhite.withValues(alpha: 0.95),
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          // Email if exists
                          if (hasEmail) ...[
                            2.hS,
                            Text(
                              email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColor.pureWhite.withValues(alpha: 0.85),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper rendering the convex curved bottom edge matching the reference image.
class _ProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Left edge down to where curve starts
    path.lineTo(0, size.height - 36.h);

    // Quadratic bezier curve to the right edge with apex in the center bottom
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 36.h,
    );

    // Right edge up to top-right corner
    path.lineTo(size.width, 0);

    // Close path along the top edge
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
