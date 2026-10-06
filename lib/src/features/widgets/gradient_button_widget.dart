import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_color.dart';
import '../../core/theme/app_font.dart';

/// Reusable gradient button widget configured with the brand linear gradient
/// (#1C9B6A to #0D4A8D) featuring a smooth morphing animation that shrinks
/// symmetrically from both sides into a circular loader when [isLoading] is true.
class GradientButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final Gradient? gradient;
  final bool isLoading;

  const GradientButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.height,
    this.width,
    this.textStyle,
    this.gradient,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColor.buttonGradientStart,
            AppColor.buttonGradientEnd,
          ],
        );

    final effectiveTextStyle = textStyle ??
        AppFont.style(
          color: AppColor.pureWhite,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveHeight = height ?? 46.h;
        final effectiveWidth = width ?? constraints.maxWidth;
        final targetWidth = isLoading ? effectiveHeight : effectiveWidth;
        final borderRadius = BorderRadius.circular(effectiveHeight / 2);

        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: targetWidth,
            height: effectiveHeight,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: effectiveGradient,
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColor.transparent,
                foregroundColor: AppColor.pureWhite,
                shadowColor: AppColor.transparent,
                disabledBackgroundColor: AppColor.transparent,
                disabledForegroundColor: AppColor.pureWhite.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('button_loader'),
                        width: effectiveHeight * 0.45,
                        height: effectiveHeight * 0.45,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.pureWhite),
                        ),
                      )
                    : FittedBox(
                        key: const ValueKey('button_text'),
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            text,
                            style: effectiveTextStyle,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
