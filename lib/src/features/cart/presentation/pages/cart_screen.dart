import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

/// Cart Screen placeholder displaying its name at the center.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColor.screenBg,
      body: Center(
        child: Text(
          'cart'.tr(),
          style: textTheme.headlineLarge?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
