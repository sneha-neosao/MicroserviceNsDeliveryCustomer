import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/verify_otp/verify_otp_bloc.dart';
import '../../bloc/verify_otp_form/verify_otp_form_bloc.dart';
import '../../widgets/verify_otp_button_widget.dart';
import '../../widgets/verify_otp_header_widget.dart';
import '../../widgets/verify_otp_image_widget.dart';
import '../../widgets/verify_otp_pin_input_widget.dart';
import '../../widgets/verify_otp_resend_widget.dart';

/// Verify OTP Screen matching the delivery design mockup:
/// - Reuses login_bg illustration at the bottom
/// - App logo, tagline with dots, and "All in One Place" divider
/// - "Verify OTP" heading and "We have sent a 6 digit OTP to your mobile number" subtitle
/// - 6-digit capsule PIN input with dash placeholders
/// - Gradient "Verify OTP" button with arrow icon
/// - [↻ Resend OTP | 00:45] timer row
class VerifyOtpScreen extends StatefulWidget {
  final String? phone;

  const VerifyOtpScreen({
    super.key,
    this.phone,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
    precacheImage(const AssetImage('assets/icons/arrow_right_icon.png'), context);
    precacheImage(const AssetImage('assets/icons/resend_icon.png'), context);
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerify(BuildContext context) {
    primaryFocus?.unfocus();
    final otp = _otpController.text.trim();
    final mobile = widget.phone?.trim() ?? '';

    if (otp.length < 6) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'enter_valid_otp_error'.tr(),
      );
      return;
    }

    context.read<VerifyOtpBloc>().add(
          VerifyOtpSubmitEvent(
            mobile: mobile,
            otp: otp,
          ),
        );
  }

  void _handleResend(BuildContext context) {
    final mobile = widget.phone?.trim() ?? '';
    context.read<VerifyOtpBloc>().add(
          VerifyOtpResendEvent(
            mobile: mobile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VerifyOtpBloc>(
          create: (_) => getIt<VerifyOtpBloc>(),
        ),
        BlocProvider<VerifyOtpFormBloc>(
          create: (_) => getIt<VerifyOtpFormBloc>(),
        ),
      ],
      child: BlocConsumer<VerifyOtpBloc, VerifyOtpState>(
        listener: (context, state) async {
          if (state is VerifyOtpSuccessState) {
            final isRegistered = state.data.data?.isRegistered ?? false;
            final message = state.data.message.isNotEmpty
                ? state.data.message
                : 'Login successful';

            if (isRegistered) {
              await SessionManager.saveVerifyOtpSession(state.data);
              if (context.mounted) {
                appSnackBar(
                  context,
                  AppColor.deliveryGreen,
                  message,
                );
                context.goNamed(AppRoute.home.name);
              }
            } else {
              if (context.mounted) {
                appSnackBar(
                  context,
                  AppColor.deliveryGreen,
                  message,
                );
                context.pushNamed(
                  AppRoute.register.name,
                  extra: widget.phone ?? '',
                );
              }
            }
          } else if (state is VerifyOtpFailureState) {
            appSnackBar(
              context,
              AppColor.bright_red,
              state.message.tr(),
            );
          } else if (state is VerifyOtpResendSuccessState) {
            appSnackBar(
              context,
              AppColor.deliveryGreen,
              state.message.tr(),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is VerifyOtpLoadingState;

          final screenHeight = MediaQuery.of(context).size.height;
          final totalHeight = math.max(screenHeight, 600.h);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: AppColor.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: AppColor.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: AppColor.screenBg,
              resizeToAvoidBottomInset: true,
              body: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: totalHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Background illustration scrolling together with content
                      const Positioned.fill(
                        child: VerifyOtpImageWidget(),
                      ),

                      // 2. Foreground content aligned in upper section
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28.w),
                          child: Column(
                            children: [
                              18.hS,

                              // Logo, tagline, "Verify OTP" title & subtitle
                              VerifyOtpHeaderWidget(phone: widget.phone),
                              24.hS,

                              // 6-digit PIN input with dash placeholders
                              VerifyOtpPinInputWidget(
                                controller: _otpController,
                                onChanged: (val) {
                                  context.read<VerifyOtpFormBloc>().add(
                                        VerifyOtpFormOtpChangedEvent(val),
                                      );
                                },
                                onCompleted: (_) => _handleVerify(context),
                              ),
                              18.hS,

                              // Verify OTP Gradient Button
                              VerifyOtpButtonWidget(
                                isLoading: isLoading,
                                onTap: () => _handleVerify(context),
                              ),
                              18.hS,

                              // [↻ Resend OTP | 00:45]
                              VerifyOtpResendWidget(
                                onResend: () => _handleResend(context),
                              ),
                              24.hS,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
