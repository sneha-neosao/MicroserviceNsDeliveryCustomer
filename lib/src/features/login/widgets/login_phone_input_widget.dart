import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Capsule mobile number text field with custom mobile phone icon.
class LoginPhoneInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const LoginPhoneInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
  });

  static const String _mobileIconAsset = 'assets/icons/mobile_icon.png';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      keyboardType: TextInputType.phone,
      style: textTheme.bodyLarge?.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.black,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        hintText: 'mobile_number_hint'.tr(),
        hintStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColor.deliveryInputHint,
        ),
        filled: true,
        fillColor: AppColor.deliveryInputBg,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 18.w, right: 12.w),
          child: Image.asset(
            _mobileIconAsset,
            width: 14.w,
            height: 22.h,
            fit: BoxFit.contain,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 44.w,
          minHeight: 22.h,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(
            color: AppColor.deliveryInputBorder,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(
            color: AppColor.deliveryInputBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(
            color: AppColor.deliveryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(
            color: AppColor.bright_red,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(
            color: AppColor.bright_red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
