import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_validator_extension.dart';
import '../../../core/theme/app_color.dart';
import '../bloc/send_otp_form/send_otp_form_bloc.dart';

/// Generic reusable text field widget parameterized with form BLoC `<T>`,
/// handling validation, input formatters, and error styling.
class LoginTextField<T> extends StatefulWidget {
  final String? label;
  final bool isRequired;
  final String hintText;
  final IconData? prefixIcon;
  final String? prefixIconAsset;
  final TextEditingController? controller;
  final bool isSecure;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final bool? readOnly;
  final TextCapitalization? textCapitalization;

  const LoginTextField({
    super.key,
    this.label,
    this.isRequired = false,
    required this.hintText,
    this.prefixIcon,
    this.prefixIconAsset,
    this.controller,
    this.isSecure = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.readOnly,
    this.textCapitalization,
  });

  @override
  State<LoginTextField<T>> createState() => _LoginTextFieldState<T>();
}

class _LoginTextFieldState<T> extends State<LoginTextField<T>> {
  bool _isVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    T? formBloc;
    try {
      formBloc = context.read<T>();
    } catch (_) {
      formBloc = null;
    }

    Widget? leadingWidget;
    if (widget.prefixIconAsset != null) {
      leadingWidget = Padding(
        padding: EdgeInsets.only(left: 18.w, right: 12.w),
        child: Image.asset(
          widget.prefixIconAsset!,
          width: 14.w,
          height: 22.h,
          fit: BoxFit.contain,
        ),
      );
    } else if (widget.prefixIcon != null) {
      leadingWidget = Icon(widget.prefixIcon, color: AppColor.deliveryInputHint);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.charcoal,
              ),
              children: [
                if (widget.isRequired)
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
          4.verticalSpace,
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: widget.isSecure ? _isVisible : false,
          onChanged: widget.onChanged,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColor.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
          textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly ?? false,
          validator: (val) {
            if (formBloc is SendOtpFormBloc) {
              if (val == null || val.trim().isEmpty) {
                return 'enter_mobile_number_error'.tr();
              } else if (!val.trim().isMobileNumberValid) {
                return 'valid_mobile_number_error'.tr();
              }
            }

            return widget.validator?.call(val);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColor.deliveryInputHint,
            ),
            prefixIcon: leadingWidget,
            prefixIconConstraints: BoxConstraints(
              minWidth: 44.w,
              minHeight: 22.h,
            ),
            suffixIcon: widget.isSecure
                ? IconButton(
                    onPressed: _toggleVisibility,
                    icon: Icon(
                      _isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7A869A),
                    ),
                  )
                : null,
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
