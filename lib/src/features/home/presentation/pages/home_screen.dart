import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../widgets/home_header_widget.dart';
import '../../widgets/select_address_bottom_sheet.dart';

/// Home Screen displaying delivery header and auto-opening address bottom sheet.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DeliveryLocationModel? _currentLocation;
  bool _hasOpenedInitialSheet = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();

    // Automatically open the address selection bottom sheet upon landing on Home Screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasOpenedInitialSheet && mounted) {
        _hasOpenedInitialSheet = true;
        _openAddressBottomSheet();
      }
    });
  }

  Future<void> _loadSavedLocation() async {
    final address = await SessionManager.getDeliveryAddress();
    final title = await SessionManager.getDeliveryAddressTitle();
    final coords = await SessionManager.getDeliveryCoordinates();

    if (mounted && address != null) {
      setState(() {
        _currentLocation = DeliveryLocationModel(
          formattedAddress: address,
          title: title ?? 'Home Delivery',
          locality: '',
          city: '',
          postalCode: '',
          latitude: coords?['lat'] ?? 0.0,
          longitude: coords?['lng'] ?? 0.0,
        );
      });
    }
  }

  Future<void> _openAddressScreen() async {
    await context.pushNamed(AppRoute.address.name);
    if (mounted) {
      _loadSavedLocation();
    }
  }

  void _openAddressBottomSheet() {
    SelectAddressBottomSheet.show(
      context,
      onLocationSelected: (selectedLocation) {
        setState(() {
          _currentLocation = selectedLocation;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Top Header with Delivery Location Selector
          HomeHeaderWidget(
            location: _currentLocation,
            onAddressTap: _openAddressScreen,
          ),

          // 2. Scrollable Home Screen Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Promotional Quick Delivery Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColor.deliveryButtonStart,
                          AppColor.deliveryButtonEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.deliveryButtonStart.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.pureWhite.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '⚡ FAST DELIVERY',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColor.pureWhite,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              8.hS,
                              Text(
                                'Fresh Groceries Delivered in 15 Mins',
                                style: textTheme.headlineMedium?.copyWith(
                                  color: AppColor.pureWhite,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                              4.hS,
                              Text(
                                'Quality groceries & daily essentials at doorstep',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColor.pureWhite.withValues(alpha: 0.9),
                                  fontSize: 11.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.wS,
                        Image.asset(
                          'assets/images/app_logo.png',
                          width: 60.w,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  20.hS,

                  // "Change Delivery Address" Card for quick access
                  GestureDetector(
                    onTap: _openAddressBottomSheet,
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColor.pureWhite,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColor.deliveryInputBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColor.deliveryGreen.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pin_drop_rounded,
                              color: AppColor.deliveryGreen,
                              size: 18.sp,
                            ),
                          ),
                          12.wS,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Location',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColor.slateGrey,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                2.hS,
                                Text(
                                  _currentLocation?.formattedAddress ??
                                      'Tap to select your delivery location',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColor.charcoal,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColor.deliveryInputHint,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  24.hS,

                  // Categories Header
                  Text(
                    'Explore Categories',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColor.charcoal,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  12.hS,

                  // Category Cards Grid
                  Row(
                    children: [
                      _CategoryCard(
                        title: 'Fresh Vegetables',
                        icon: Icons.eco_rounded,
                        color: AppColor.deliveryGreen,
                      ),
                      12.wS,
                      _CategoryCard(
                        title: 'Dairy & Eggs',
                        icon: Icons.egg_alt_rounded,
                        color: AppColor.deliveryButtonStart,
                      ),
                      12.wS,
                      _CategoryCard(
                        title: 'Beverages',
                        icon: Icons.local_drink_rounded,
                        color: AppColor.buttonGradientEnd,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColor.pureWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColor.deliveryInputBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22.sp,
              ),
            ),
            8.hS,
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColor.charcoal,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
