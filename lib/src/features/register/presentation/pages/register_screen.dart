import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/register/register_bloc.dart';
import '../../bloc/register_form/register_form_bloc.dart';
import '../../widgets/register_button_widget.dart';
import '../../widgets/register_header_widget.dart';
import '../../widgets/register_image_widget.dart';
import '../../widgets/register_input_widget.dart';

/// Register Screen matching the delivery design aesthetics:
/// - Reuses the login background image asset (`assets/images/login.png`)
/// - App logo, tagline with dots, and "All in One Place" divider
/// - "Register" heading and subtitle
/// - Full Name, Email Address, and prefilled Mobile Number fields
/// - Dual-BLoC architecture: RegisterBloc (API execution) & RegisterFormBloc (input validation)
/// - Gradient "Submit" button triggering the register API
class RegisterScreen extends StatefulWidget {
  final String? mobile;

  const RegisterScreen({
    super.key,
    this.mobile,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController(text: widget.mobile ?? '');

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
    precacheImage(const AssetImage('assets/icons/profile_icon.png'), context);
    precacheImage(const AssetImage('assets/icons/email_icon.png'), context);
    precacheImage(const AssetImage('assets/icons/mobile_icon.png'), context);
    precacheImage(const AssetImage('assets/icons/arrow_right_icon.png'), context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();

    if (name.isEmpty) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'Please enter your full name',
      );
      return;
    }

    if (mobile.isEmpty) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'enter_mobile_number_error'.tr(),
      );
      return;
    }

    if (!mobile.isMobileNumberValid) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'valid_mobile_number_error'.tr(),
      );
      return;
    }

    // Email is optional: validate format only if provided
    if (email.isNotEmpty && !email.isEmailValid) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'please_enter_valid_email'.tr(),
      );
      return;
    }

    context.read<RegisterBloc>().add(
          RegisterSubmitEvent(
            name: name,
            email: email.isNotEmpty ? email : null,
            contact: mobile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterBloc>(
          create: (_) => getIt<RegisterBloc>(),
        ),
        BlocProvider<RegisterFormBloc>(
          create: (_) => getIt<RegisterFormBloc>()
            ..add(
              RegisterFormInitializeEvent(
                contact: widget.mobile,
              ),
            ),
        ),
      ],
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) async {
          if (state is RegisterSuccessState) {
            final message = state.data.message.isNotEmpty
                ? state.data.message
                : 'Registration successful';

            await SessionManager.saveRegisterSession(state.data);

            if (context.mounted) {
              appSnackBar(
                context,
                AppColor.deliveryGreen,
                message,
              );
              context.goNamed(AppRoute.home.name);
            }
          } else if (state is RegisterFailureState) {
            appSnackBar(
              context,
              AppColor.bright_red,
              state.message.tr(),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoadingState;
          final screenHeight = MediaQuery.of(context).size.height;
          final totalHeight = math.max(screenHeight, 620.h);

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
                      // 1. Background image (same as login screen) scrolling together with content
                      const Positioned.fill(
                        child: RegisterImageWidget(),
                      ),

                      // 2. Foreground form content aligned in upper section
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28.w),
                          child: Column(
                            children: [
                              18.hS,

                              // Logo, tagline, and title
                              const RegisterHeaderWidget(),
                              24.hS,

                              // Input fields (Name, Email, Mobile)
                              RegisterInputWidget(
                                nameController: _nameController,
                                emailController: _emailController,
                                mobileController: _mobileController,
                              ),
                              20.hS,

                              // Submit Button with loading state and API call
                              RegisterButtonWidget(
                                isLoading: isLoading,
                                onTap: () => _handleSubmit(context),
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
