import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Shimmer skeleton loader matching the Home Screen layout:
/// - 2 Main category cards
/// - Banner placeholder
/// - Category list placeholder
/// - Product list cards
class HomeShimmerWidget extends StatelessWidget {
  const HomeShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2 Main categories row placeholder
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 115.h,
                  decoration: BoxDecoration(
                    color: AppColor.deliveryInputBg,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
              12.wS,
              Expanded(
                child: Container(
                  height: 115.h,
                  decoration: BoxDecoration(
                    color: AppColor.deliveryInputBg,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ],
          ),
          20.hS,

          // Banner placeholder
          Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.deliveryInputBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          20.hS,

          // Category list placeholder
          Container(
            width: 130.w,
            height: 18.h,
            color: AppColor.deliveryInputBg,
          ),
          12.hS,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => Column(
                children: [
                  Container(
                    width: 66.w,
                    height: 66.w,
                    decoration: BoxDecoration(
                      color: AppColor.deliveryInputBg,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  6.hS,
                  Container(
                    width: 50.w,
                    height: 10.h,
                    color: AppColor.deliveryInputBg,
                  ),
                ],
              ),
            ),
          ),
          22.hS,

          // Product list placeholder
          Container(
            width: 140.w,
            height: 18.h,
            color: AppColor.deliveryInputBg,
          ),
          12.hS,
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 210.h,
                  decoration: BoxDecoration(
                    color: AppColor.deliveryInputBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              12.wS,
              Expanded(
                child: Container(
                  height: 210.h,
                  decoration: BoxDecoration(
                    color: AppColor.deliveryInputBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
