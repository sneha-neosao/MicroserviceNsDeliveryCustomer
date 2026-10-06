import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// Main container screen for the ShellRoute hosting the 4 bottom navigation tabs:
/// Stations, My Charge, History, and Profile.
class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoute.home.path)) {
      return 0;
    }
    if (location.startsWith(AppRoute.search.path)) {
      return 1;
    }
    if (location.startsWith(AppRoute.cart.path)) {
      return 2;
    }
    if (location.startsWith(AppRoute.profile.path)) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoute.home.name);
        break;
      case 1:
        context.goNamed(AppRoute.search.name);
        break;
      case 2:
        context.goNamed(AppRoute.cart.name);
        break;
      case 3:
        context.goNamed(AppRoute.profile.name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.screenBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          if (selectedIndex != 0) {
            context.goNamed(AppRoute.home.name);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.screenBg,
          body: Stack(
            children: [
              // Active Tab Page Screen
              Positioned.fill(
                child: widget.child,
              ),

              // Floating Bottom Navigation Capsule
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 14.h,
                    ),
                    child: CustomBottomNavBar(
                      currentIndex: selectedIndex,
                      onTap: (index) => _onItemTapped(index, context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
