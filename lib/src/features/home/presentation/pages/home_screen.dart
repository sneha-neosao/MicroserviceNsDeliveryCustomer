import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Home Screen placeholder displaying its name at the center.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColor.screenBg,
      body: Center(
        child: Text(
          'home'.tr(),
          style: textTheme.headlineLarge?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
