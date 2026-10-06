import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/send_otp_form/send_otp_form_bloc.dart';
import 'login_text_field.dart';

/// Encapsulated Form Input Widget grouping the mobile number text field
/// and dispatching input change events to [SendOtpFormBloc].
class LoginInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const LoginInputWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<SendOtpFormBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoginTextField<SendOtpFormBloc>(
          controller: controller,
          hintText: 'mobile_number_hint'.tr(),
          prefixIconAsset: 'assets/icons/mobile_icon.png',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (val) {
            formBloc.add(SendOtpFormMobileChangedEvent(val));
          },
        ),
      ],
    );
  }
}
