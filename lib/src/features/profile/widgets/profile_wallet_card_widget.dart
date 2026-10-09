import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Wallet balance card matching the reference design:
/// - "Wallet Balance" label with wallet icon
/// - Large balance amount ("₹ 0") with Skeletonizer loader
/// - Points badge ("0 Points") with Skeletonizer loader
/// - "Add Money ->" orange pill button
/// - Illustrated wallet with floating gold coins and "Shop More Save More!" tagline
class ProfileWalletCardWidget extends StatelessWidget {
  final bool isLoading;
  final num rupees;
  final num points;
  final VoidCallback? onAddMoneyTap;

  const ProfileWalletCardWidget({
    super.key,
    this.isLoading = false,
    this.rupees = 0,
    this.points = 0,
    this.onAddMoneyTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.walletCardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColor.walletCardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.deliveryButtonStart.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Balance & Add Money Button
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColor.deliveryButtonStart,
                            size: 17.sp,
                          ),
                          6.wS,
                          Text(
                            'Wallet Balance',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColor.slateGrey,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      6.hS,

                      // Big Amount & Points with Skeletonizer
                      Skeletonizer(
                        enabled: isLoading,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Big Amount
                            Text(
                              '₹ ${rupees is int || rupees % 1 == 0 ? rupees.toInt() : rupees.toStringAsFixed(2)}',
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColor.charcoal,
                                fontWeight: FontWeight.w800,
                                fontSize: 24.sp,
                                letterSpacing: 0.3,
                              ),
                            ),
                            4.hS,
                            // Points Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.deliveryButtonStart
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    color: AppColor.deliveryButtonStart,
                                    size: 14.sp,
                                  ),
                                  4.wS,
                                  Text(
                                    '$points Points',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColor.deliveryButtonStart,
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      12.hS,


                      // Add Money Button
                      GestureDetector(
                        onTap: onAddMoneyTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColor.deliveryButtonStart,
                                AppColor.deliveryButtonEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.deliveryButtonStart
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add Money',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColor.pureWhite,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                              6.wS,
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColor.pureWhite,
                                size: 14.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Column: Wallet graphic with coins & tagline
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 110.h,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Tagline text at top-right
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Text(
                            'Shop More\nSave More!',
                            textAlign: TextAlign.right,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColor.deliveryButtonStart,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),

                        // Floating Coin 1 (Top Left)
                        Positioned(
                          top: 20.h,
                          left: 14.w,
                          child: _FloatingCoinWidget(size: 26.w),
                        ),

                        // Floating Coin 2 (Center)
                        Positioned(
                          top: 8.h,
                          left: 48.w,
                          child: _FloatingCoinWidget(size: 30.w),
                        ),

                        // Floating green leaf on left
                        Positioned(
                          left: 0,
                          bottom: 24.h,
                          child: Transform.rotate(
                            angle: -0.4,
                            child: Icon(
                              Icons.eco_rounded,
                              color: AppColor.deliveryGreen,
                              size: 18.sp,
                            ),
                          ),
                        ),

                        // Floating green leaf on right
                        Positioned(
                          right: 0,
                          bottom: 24.h,
                          child: Transform.rotate(
                            angle: 0.4,
                            child: Icon(
                              Icons.eco_rounded,
                              color: AppColor.deliveryGreen,
                              size: 18.sp,
                            ),
                          ),
                        ),

                        // Main 3D Styled Wallet
                        Positioned(
                          bottom: 0,
                          right: 12.w,
                          child: Container(
                            width: 78.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColor.deliveryButtonStart,
                                  AppColor.darkOrange,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.deliveryButtonStart
                                      .withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                // Wallet Clasp Flap
                                Positioned(
                                  right: 6.w,
                                  child: Container(
                                    width: 18.w,
                                    height: 22.h,
                                    decoration: BoxDecoration(
                                      color: AppColor.orangeTint,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 7.w,
                                        height: 7.w,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColor.goldCoin,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper golden coin with rupee symbol
class _FloatingCoinWidget extends StatelessWidget {
  final double size;

  const _FloatingCoinWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            AppColor.goldCoinLight,
            AppColor.goldCoin,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.goldCoinDark.withValues(alpha: 0.35),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColor.goldCoinDark,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '₹',
          style: TextStyle(
            color: AppColor.pureWhite,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
