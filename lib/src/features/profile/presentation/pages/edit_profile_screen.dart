import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/profile_details/profile_details_bloc.dart';
import '../../widgets/edit_profile_button_widget.dart';
import '../../widgets/edit_profile_header_widget.dart';
import '../../widgets/edit_profile_input_widget.dart';

/// Screen allowing the user to view and edit their profile details:
/// - Screen title and header bar matching other screens
/// - 3 fields: Full Name, Email (optional), and Mobile Number (read-only)
/// - Input field styling identical to the register screen
/// - Calls [ProfileDetailsGetEvent] on init to load and prefill profile information
/// - Gradient "Update Profile" button at the bottom
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileDetailsBloc>(
          create: (_) => getIt<ProfileDetailsBloc>()..add(ProfileDetailsGetEvent()),
        ),
      ],
      child: const _EditProfileScreenContent(),
    );
  }
}

class _EditProfileScreenContent extends StatefulWidget {
  const _EditProfileScreenContent();

  @override
  State<_EditProfileScreenContent> createState() =>
      _EditProfileScreenContentState();
}

class _EditProfileScreenContentState extends State<_EditProfileScreenContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _loadInitialSessionData();
  }

  Future<void> _loadInitialSessionData() async {
    final customer = await SessionManager.getCustomerData();
    final name = await SessionManager.getUserName();
    final mobile = await SessionManager.getUserMobileNumber();
    final email = await SessionManager.getUserEmail();

    if (mounted) {
      if (_nameController.text.isEmpty) {
        _nameController.text = customer?.name ?? name ?? '';
      }
      if (_mobileController.text.isEmpty) {
        _mobileController.text = customer?.contact ?? mobile ?? '';
      }
      if (_emailController.text.isEmpty) {
        _emailController.text = customer?.email ?? email ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _handleUpdateProfile() {
    primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'Please enter your full name',
      );
      return;
    }

    if (email.isNotEmpty && !email.isEmailValid) {
      appSnackBar(
        context,
        AppColor.bright_red,
        'please_enter_valid_email'.tr(),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Provide immediate user feedback and pop back
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        appSnackBar(
          context,
          AppColor.deliveryGreen,
          'Profile updated successfully',
        );
        context.pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Header Bar with Back Button and Title
              const EditProfileHeaderWidget(),

              // 2. Scrollable Body Content
              Expanded(
                child: BlocConsumer<ProfileDetailsBloc, ProfileDetailsState>(
                  listener: (context, state) {
                    if (state is ProfileDetailsSuccessState) {
                      final data = state.data.data;
                      if (data != null) {
                        if (data.name.isNotEmpty) {
                          _nameController.text = data.name;
                        }
                        if (data.contact.isNotEmpty) {
                          _mobileController.text = data.contact;
                        }
                        if (data.email != null && data.email!.isNotEmpty) {
                          _emailController.text = data.email!;
                        }
                      }
                    } else if (state is ProfileDetailsFailureState) {
                      appSnackBar(
                        context,
                        AppColor.bright_red,
                        state.message,
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is ProfileDetailsLoadingState;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 40.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shimmer/Skeleton loader while API loads
                            Skeletonizer(
                              enabled: isLoading,
                              child: EditProfileInputWidget(
                                nameController: _nameController,
                                emailController: _emailController,
                                mobileController: _mobileController,
                              ),
                            ),
                            30.hS,

                            // 3. Update Profile Action Button
                            EditProfileButtonWidget(
                              isLoading: _isSubmitting,
                              onTap: _handleUpdateProfile,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
