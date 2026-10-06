import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/send_otp/send_otp_bloc.dart';
import '../../bloc/send_otp_form/send_otp_form_bloc.dart';
import '../../widgets/login_header_widget.dart';
import '../../widgets/login_image_widget.dart';
import '../../widgets/login_input_widget.dart';
import '../../widgets/login_send_otp_button_widget.dart';
import '../../widgets/login_terms_widget.dart';

/// Login Screen matching the delivery design mockup:
/// - MultiBlocProvider injecting SendOtpBloc and SendOtpFormBloc
/// - Background illustration with groceries at the bottom
/// - App logo, tagline with dots, and "All in One Place" divider
/// - "Welcome Back!" heading and subtitle
/// - LoginInputWidget housing `LoginTextField<SendOtpFormBloc>`
/// - Gradient "Send OTP" button with loading indicator and API dispatch
/// - Terms & Conditions agreement footer
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
    precacheImage(const AssetImage('assets/icons/mobile_icon.png'), context);
    precacheImage(const AssetImage('assets/icons/arrow_right_icon.png'), context);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOtp(BuildContext context) {
    primaryFocus?.unfocus();
    final phone = _phoneController.text.trim();
    context.read<SendOtpBloc>().add(SendOtpSubmitEvent(phone));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final totalHeight = math.max(screenHeight, 600.h);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SendOtpBloc>()),
        BlocProvider(create: (_) => getIt<SendOtpFormBloc>()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                  // 1. Background image scrolling together with the content
                  const Positioned.fill(
                    child: LoginImageWidget(),
                  ),

                  // 2. Foreground form content aligned in upper section
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Column(
                        children: [
                          18.hS,

                          // Logo, tagline, title & subtitle
                          const LoginHeaderWidget(),
                          24.hS,

                          // Encapsulated Mobile Number Input Widget
                          LoginInputWidget(
                            controller: _phoneController,
                          ),
                          14.hS,

                          // Send OTP Gradient Button listening to SendOtpBloc
                          BlocConsumer<SendOtpBloc, SendOtpState>(
                            listener: (context, state) {
                              if (state is SendOtpFailureState) {
                                appSnackBar(
                                  context,
                                  AppColor.bright_red,
                                  state.message,
                                );
                              } else if (state is SendOtpSuccessState) {
                                appSnackBar(
                                  context,
                                  AppColor.deliveryGreen,
                                  state.data.message,
                                );
                                final targetMobile = state.data.data?.mobile.isNotEmpty == true
                                    ? state.data.data!.mobile
                                    : _phoneController.text.trim();
                                context.pushNamed(
                                  AppRoute.otp.name,
                                  extra: targetMobile,
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is SendOtpLoadingState;
                              return LoginSendOtpButtonWidget(
                                isLoading: isLoading,
                                onTap: () => _handleSendOtp(context),
                              );
                            },
                          ),
                          14.hS,

                          // Terms and Conditions text
                          const LoginTermsWidget(),
                          20.hS,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
