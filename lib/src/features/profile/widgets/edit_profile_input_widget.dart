import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/extensions/string_validator_extension.dart';
import 'edit_profile_text_field.dart';

/// Container grouping the 3 edit profile fields:
/// - Full Name (Editable, Mandatory)
/// - Email Address (Editable, Optional)
/// - Mobile Number (Read-only, Mandatory)
class EditProfileInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;

  const EditProfileInputWidget({
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
        // 1. Full Name Field (Editable, Mandatory)
        EditProfileTextField(
          controller: nameController,
          label: 'Full Name',
          isRequired: true,
          hintText: 'Enter your full name *',
          prefixIconAsset: _profileIconAsset,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        16.hS,

        // 2. Email Address Field (Editable, Optional)
        EditProfileTextField(
          controller: emailController,
          label: 'Email Address',
          isRequired: false,
          hintText: 'Enter your email address (Optional)',
          prefixIconAsset: _emailIconAsset,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val != null && val.trim().isNotEmpty && !val.trim().isEmailValid) {
              return 'please_enter_valid_email'.tr();
            }
            return null;
          },
        ),
        16.hS,

        // 3. Mobile Number Field (Read-only)
        EditProfileTextField(
          controller: mobileController,
          label: 'Mobile Number',
          isRequired: true,
          hintText: 'Mobile number',
          prefixIconAsset: _mobileIconAsset,
          keyboardType: TextInputType.phone,
          readOnly: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }
}
