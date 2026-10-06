import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';

/// Resend OTP widget matching the provided design:
/// [↻ Resend OTP  |  00:45]
class VerifyOtpResendWidget extends StatefulWidget {
  final VoidCallback onResend;
  final int initialSeconds;

  const VerifyOtpResendWidget({
    super.key,
    required this.onResend,
    this.initialSeconds = 45,
  });

  static const String _resendIconAsset = 'assets/icons/resend_icon.png';

  @override
  State<VerifyOtpResendWidget> createState() => _VerifyOtpResendWidgetState();
}

class _VerifyOtpResendWidgetState extends State<VerifyOtpResendWidget> {
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _handleResend() {
    if (_secondsRemaining > 0) return;

    widget.onResend();
    setState(() {
      _secondsRemaining = widget.initialSeconds;
    });
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canResend = _secondsRemaining == 0;
    final formattedTime =
        '00:${_secondsRemaining.toString().padLeft(2, '0')}';

    final resendColor =
        canResend ? AppColor.deliveryGreen : AppColor.slateGrey;
    final timerColor =
        canResend ? AppColor.slateGrey : AppColor.deliveryGreen;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Resend Icon & Text Clickable Row
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canResend ? _handleResend : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                VerifyOtpResendWidget._resendIconAsset,
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
                color: resendColor,
              ),
              8.wS,
              Text(
                'resend_otp'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: resendColor,
                ),
              ),
            ],
          ),
        ),
        14.wS,

        // Vertical Divider
        Container(
          width: 1.w,
          height: 16.h,
          color: AppColor.deliveryGreen,
        ),
        14.wS,

        // Countdown Timer Text
        Text(
          formattedTime,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: timerColor,
          ),
        ),
      ],
    );
  }
}
