import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Text field widget for the register screen with identical styling to the login screen's mobile field:
/// - Rounded capsule border with `AppColor.deliveryInputBorder` and `AppColor.deliveryInputBg`
/// - Prefix asset icon tinted with `AppColor.deliveryGreen` (`046404`)
/// - Poppins typography and theme styling
class RegisterTextField extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final String hintText;
  final String prefixIconAsset;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final TextCapitalization textCapitalization;

  const RegisterTextField({
    super.key,
    this.label,
    this.isRequired = false,
    required this.hintText,
    required this.prefixIconAsset,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.charcoal,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColor.bright_red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
          6.verticalSpace,
        ],
        TextFormField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: textTheme.bodyLarge?.copyWith(
        color: AppColor.black,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColor.deliveryInputHint,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 18.w, right: 12.w),
          child: Image.asset(
            prefixIconAsset,
            width: 18.w,
            height: 18.w,
            color: AppColor.deliveryGreen, // 046404
            fit: BoxFit.contain,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 48.w,
          minHeight: 22.h,
        ),
        filled: true,
        fillColor: AppColor.deliveryInputBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          color: AppColor.bright_red,
          height: 1.2,
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
    ),
  ],
);
  }
}
