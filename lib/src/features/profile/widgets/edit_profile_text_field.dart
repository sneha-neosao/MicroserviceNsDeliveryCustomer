import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// Text field widget for the edit profile screen with identical styling to the register screen:
/// - Rounded capsule border with [AppColor.deliveryInputBorder] and [AppColor.deliveryInputBg]
/// - Prefix asset icon tinted with [AppColor.deliveryGreen]
/// - Poppins typography via [Theme.of(context).textTheme]
/// - Optional read-only styling with a subtle lock indicator
class EditProfileTextField extends StatelessWidget {
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
  final Widget? suffixIcon;

  const EditProfileTextField({
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
    this.suffixIcon,
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
            color: readOnly ? AppColor.slateGrey : AppColor.black,
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
                color: readOnly
                    ? AppColor.slateGrey
                    : AppColor.deliveryGreen,
                fit: BoxFit.contain,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 48.w,
              minHeight: 22.h,
            ),
            suffixIcon: suffixIcon ??
                (readOnly
                    ? Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 18.sp,
                          color: AppColor.slateGrey,
                        ),
                      )
                    : null),
            suffixIconConstraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 22.h,
            ),
            filled: true,
            fillColor: readOnly
                ? AppColor.deliveryInputBg.withValues(alpha: 0.6)
                : AppColor.deliveryInputBg,
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
              borderSide: BorderSide(
                color: readOnly
                    ? AppColor.deliveryInputBorder
                    : AppColor.deliveryGreen,
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
