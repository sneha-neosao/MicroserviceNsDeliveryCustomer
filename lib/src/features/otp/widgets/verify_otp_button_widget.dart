import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Vibrant gradient button with "Verify OTP" text and trailing arrow right icon.
class VerifyOtpButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const VerifyOtpButtonWidget({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  static const String _arrowIconAsset = 'assets/icons/arrow_right_icon.png';

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.pureWhite,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        'verify_otp'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColor.pureWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        _arrowIconAsset,
                        width: 18.w,
                        height: 18.h,
                        fit: BoxFit.contain,
                      ),
                      20.wS,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
