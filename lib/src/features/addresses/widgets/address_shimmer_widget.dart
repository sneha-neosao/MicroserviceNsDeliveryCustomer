import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Shimmer skeleton card for address list while API response is loading.
class AddressShimmerWidget extends StatelessWidget {
  const AddressShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColor.pureWhite,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColor.deliveryInputBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppColor.deliveryInputBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                  10.wS,
                  Container(
                    width: 70.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColor.deliveryInputBg,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  8.wS,
                  Container(
                    width: 50.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColor.deliveryInputBg,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppColor.deliveryInputBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              12.hS,
              Container(
                width: 140.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColor.deliveryInputBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              8.hS,
              Container(
                width: double.infinity,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColor.deliveryInputBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              6.hS,
              Container(
                width: 180.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColor.deliveryInputBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
