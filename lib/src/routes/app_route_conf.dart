import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/addresses/presentation/pages/address_screen.dart';
import '../features/addresses/presentation/pages/select_location_screen.dart';
import '../features/cart/presentation/pages/cart_screen.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/login/presentation/pages/login_screen.dart';
import '../features/main_screen/presentation/pages/main_screen.dart';
import '../features/otp/presentation/pages/verify_otp_screen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/register/presentation/pages/register_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
import '../features/splash/presentation/pages/splash_screen.dart';
import 'app_route_path.dart';

final GlobalKey<NavigatorState> globalNavigator = GlobalKey<NavigatorState>();

class AppRouteConf {
  GoRouter get router => _router;

  late final _router = GoRouter(
    navigatorKey: globalNavigator,
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,

    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        pageBuilder: (context, state) {
          return _fadePage(const SplashScreen());
        },
      ),

      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        pageBuilder: (context, state) {
          return _fadePage(const LoginScreen());
        },
      ),

      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.name,
        pageBuilder: (context, state) {
          final phone = state.extra as String?;
          return _fadePage(VerifyOtpScreen(phone: phone));
        },
      ),

      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        pageBuilder: (context, state) {
          final mobile = state.extra as String?;
          return _fadePage(RegisterScreen(mobile: mobile));
        },
      ),

      GoRoute(
        path: AppRoute.selectLocation.path,
        name: AppRoute.selectLocation.name,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, double>?;
          return _fadePage(
            SelectLocationScreen(
              initialLat: extra?['lat'],
              initialLng: extra?['lng'],
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoute.address.path,
        name: AppRoute.address.name,
        pageBuilder: (context, state) {
          return _fadePage(const AddressScreen());
        },
      ),

      // Shell route for bottom navigation bar screens
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            name: AppRoute.home.name,
            pageBuilder: (context, state) => _fadePage(const HomeScreen()),
          ),
          GoRoute(
            path: AppRoute.search.path,
            name: AppRoute.search.name,
            pageBuilder: (context, state) => _fadePage(const SearchScreen()),
          ),
          GoRoute(
            path: AppRoute.cart.path,
            name: AppRoute.cart.name,
            pageBuilder: (context, state) => _fadePage(const CartScreen()),
          ),
          GoRoute(
            path: AppRoute.profile.path,
            name: AppRoute.profile.name,
            pageBuilder: (context, state) => _fadePage(const ProfileScreen()),
          ),
        ],
      ),
    ],
  );
}

/// Fade transition page helper

CustomTransitionPage _fadePage(Widget child) => CustomTransitionPage(
  transitionDuration: const Duration(
    milliseconds: 500,
  ), // Duration of the animation
  child: child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut, // Smooth in-out fade
    );

    return FadeTransition(opacity: curvedAnimation, child: child);
  },
);
