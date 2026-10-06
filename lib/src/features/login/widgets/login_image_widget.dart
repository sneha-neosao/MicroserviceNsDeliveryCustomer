import 'package:flutter/material.dart';

/// Full-screen display of the login asset image.
class LoginImageWidget extends StatelessWidget {
  const LoginImageWidget({super.key});

  static const String _loginImageAsset = 'assets/images/login.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _loginImageAsset,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }
}
