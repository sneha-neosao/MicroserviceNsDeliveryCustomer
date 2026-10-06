import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/extensions/string_validator_extension.dart';
import '../bloc/register_form/register_form_bloc.dart';
import 'register_text_field.dart';

/// Form inputs container widget for registration: Full Name, Email, and Mobile Number.
/// Styled identically to the mobile number field on the login screen.
class RegisterInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;

  const RegisterInputWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.mobileController,
  });

  static const String _profileIconAsset = 'assets/icons/profile_icon.png';
  static const String _emailIconAsset = 'assets/icons/email_icon.png';
  static const String _mobileIconAsset = 'assets/icons/mobile_icon.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name Field (Mandatory)
        RegisterTextField(
          controller: nameController,
          hintText: 'Enter your full name *',
          prefixIconAsset: _profileIconAsset,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          onChanged: (val) {
            context.read<RegisterFormBloc>().add(RegisterFormNameChangedEvent(val));
          },
        ),
        16.hS,

        // Email Field (Optional - only validated if entered)
        RegisterTextField(
          controller: emailController,
          hintText: 'Enter your email address',
          prefixIconAsset: _emailIconAsset,
          keyboardType: TextInputType.emailAddress,
          onChanged: (val) {
            context.read<RegisterFormBloc>().add(RegisterFormEmailChangedEvent(val));
          },
          validator: (val) {
            if (val != null && val.trim().isNotEmpty && !val.trim().isEmailValid) {
              return 'please_enter_valid_email'.tr();
            }
            return null;
          },
        ),
        16.hS,

        // Mobile Number Field (Mandatory - prefilled)
        RegisterTextField(
          controller: mobileController,
          hintText: 'Enter mobile number *',
          prefixIconAsset: _mobileIconAsset,
          keyboardType: TextInputType.phone,
          readOnly: true,
          onChanged: (val) {
            context.read<RegisterFormBloc>().add(RegisterFormContactChangedEvent(val));
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }
}
