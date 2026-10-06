import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../bloc/splash/splash_bloc.dart';
import '../../widgets/splash_image_reveal_widget.dart';

/// Splash screen displaying the splash image with smooth blur-to-clear and shimmer animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // System UI overlay configuration for seamless edge-to-edge presentation
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/splash.png'), context);
    precacheImage(const AssetImage('assets/images/login.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(
          create: (_) => getIt<SplashBloc>()..add(SplashInitEvent()),
        ),
      ],
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is SplashAuthenticatedState ||
              (state is SplashLoadedState && state.isLoggedIn)) {
            context.goNamed(AppRoute.home.name);
          } else if (state is SplashUnauthenticatedState ||
              (state is SplashLoadedState && !state.isLoggedIn)) {
            context.goNamed(AppRoute.login.name);
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColor.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: const Scaffold(
            backgroundColor: AppColor.black,
            body: SplashImageRevealWidget(),
          ),
        ),
      ),
    );
  }
}
