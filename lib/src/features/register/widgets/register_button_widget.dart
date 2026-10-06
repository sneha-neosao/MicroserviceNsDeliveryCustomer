import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Reusable gradient button for registration.
class RegisterButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const RegisterButtonWidget({
    super.key,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        gradient: const LinearGradient(
          colors: [
            AppColor.deliveryButtonStart,
            AppColor.deliveryButtonEnd,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.deliveryButtonStart.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30.r),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.pureWhite),
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Submit',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.pureWhite,
                              letterSpacing: 0.5,
                            ),
                      ),
                      8.horizontalSpace,
                      Image.asset(
                        'assets/icons/arrow_right_icon.png',
                        width: 14.w,
                        height: 14.w,
                        color: AppColor.pureWhite,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
