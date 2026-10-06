import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_color.dart';

/// 6-digit OTP pin input widget with rounded capsules and dash placeholders,
/// exactly matching the provided UI design.
class VerifyOtpPinInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const VerifyOtpPinInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<VerifyOtpPinInputWidget> createState() => _VerifyOtpPinInputWidgetState();
}

class _VerifyOtpPinInputWidgetState extends State<VerifyOtpPinInputWidget> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {});
    final text = widget.controller.text;
    widget.onChanged?.call(text);
    if (text.length == 6) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = widget.controller.text;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Hidden real text field for native mobile keyboard input & autofill
        Positioned.fill(
          child: Opacity(
            opacity: 0.0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
          ),
        ),

        // Visual 6-cell layout
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final isFilled = index < text.length;
              final isCurrent = _focusNode.hasFocus &&
                  (index == text.length || (text.length == 6 && index == 5));

              return Container(
                width: 46.w,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.deliveryInputBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isCurrent
                        ? AppColor.deliveryGreen
                        : AppColor.deliveryInputBorder,
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isFilled
                    ? Text(
                        text[index],
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      )
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }
}
