import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Profile Screen placeholder displaying its name at the center.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColor.screenBg,
      body: Center(
        child: Text(
          'profile'.tr(),
          style: textTheme.headlineLarge?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
