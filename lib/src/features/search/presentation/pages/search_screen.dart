import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Search Screen placeholder displaying its name at the center.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColor.screenBg,
      body: Center(
        child: Text(
          'search'.tr(),
          style: textTheme.headlineLarge?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
