import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Quick actions section featuring a 2x2 grid of cards matching the design:
/// - My Orders (Track your orders)
/// - My Wishlist (Saved for later)
/// - Wallet History (View transactions)
/// - My Coupons (Grab exciting offers)
class ProfileQuickActionsWidget extends StatelessWidget {
  final VoidCallback? onOrdersTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onWalletHistoryTap;
  final VoidCallback? onCouponsTap;

  const ProfileQuickActionsWidget({
    super.key,
    this.onOrdersTap,
    this.onWishlistTap,
    this.onWalletHistoryTap,
    this.onCouponsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w800,
            fontSize: 16.5.sp,
          ),
        ),
        12.hS,

        // Row 1: My Orders & My Wishlist
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                bgColor: AppColor.quickActionOrdersBg,
                iconWidget: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColor.cardboardBox.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: AppColor.cardboardBox,
                      size: 22.sp,
                    ),
                  ),
                ),
                title: 'My Orders',
                subtitle: 'Track your orders',
                onTap: onOrdersTap,
              ),
            ),
            12.wS,
            Expanded(
              child: _QuickActionCard(
                bgColor: AppColor.quickActionWishlistBg,
                iconWidget: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColor.heartRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppColor.heartRed,
                      size: 22.sp,
                    ),
                  ),
                ),
                title: 'My Wishlist',
                subtitle: 'Saved for later',
                onTap: onWishlistTap,
              ),
            ),
          ],
        ),
        12.hS,

        // Row 2: Wallet History & My Coupons
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                bgColor: AppColor.quickActionHistoryBg,
                iconWidget: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColor.deliveryButtonStart.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColor.deliveryButtonStart,
                      size: 22.sp,
                    ),
                  ),
                ),
                title: 'Wallet History',
                subtitle: 'View transactions',
                onTap: onWalletHistoryTap,
              ),
            ),
            12.wS,
            Expanded(
              child: _QuickActionCard(
                bgColor: AppColor.quickActionCouponsBg,
                iconWidget: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColor.couponRed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.confirmation_number_rounded,
                      color: AppColor.couponRed,
                      size: 22.sp,
                    ),
                  ),
                ),
                title: 'My Coupons',
                subtitle: 'Grab exciting offers',
                onTap: onCouponsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final Color bgColor;
  final Widget iconWidget;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.bgColor,
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.profileCardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Row(
              children: [
                // Icon
                iconWidget,
                8.wS,

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColor.charcoal,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5.sp,
                        ),
                      ),
                      2.hS,
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColor.slateGrey,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                4.wS,

                // Orange circular forward arrow
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: AppColor.deliveryButtonStart,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColor.pureWhite,
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
