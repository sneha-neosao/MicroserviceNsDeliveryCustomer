import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/services/location_service.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/theme/app_color.dart';
import '../../widgets/snackbar_widget.dart';
import '../../addresses/presentation/pages/select_location_screen.dart';

/// Modal bottom sheet for choosing delivery address with:
/// - Outside top-center circular grey close button with white 0.5 border
/// - 2 options in a small row: [Use Current Location] and [Add New Location]
class SelectAddressBottomSheet extends StatefulWidget {
  final ValueChanged<DeliveryLocationModel>? onLocationSelected;

  const SelectAddressBottomSheet({
    super.key,
    this.onLocationSelected,
  });

  /// Displays the modal bottom sheet smoothly with transparent backdrop.
  static Future<DeliveryLocationModel?> show(
    BuildContext context, {
    ValueChanged<DeliveryLocationModel>? onLocationSelected,
  }) {
    return showModalBottomSheet<DeliveryLocationModel>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColor.transparent,
      barrierColor: AppColor.black.withValues(alpha: 0.55),
      builder: (_) => SelectAddressBottomSheet(
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  State<SelectAddressBottomSheet> createState() =>
      _SelectAddressBottomSheetState();
}

class _SelectAddressBottomSheetState extends State<SelectAddressBottomSheet> {
  bool _isLoadingCurrentLocation = false;
  String? _savedAddress;
  String? _savedTitle;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final address = await SessionManager.getDeliveryAddress();
    final title = await SessionManager.getDeliveryAddressTitle();
    if (mounted && address != null) {
      setState(() {
        _savedAddress = address;
        _savedTitle = title ?? 'Current Delivery Location';
      });
    }
  }

  Future<void> _handleUseCurrentLocation() async {
    if (_isLoadingCurrentLocation) return;
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    final position = await LocationService.getCurrentPosition();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
      appSnackBar(
        context,
        AppColor.bright_red,
        'Please enable location services and grant permission to detect address.',
      );
      return;
    }

    final location = await LocationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingCurrentLocation = false;
    });

    final finalLocation = location ??
        DeliveryLocationModel(
          formattedAddress:
              'GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
          title: 'Current Location',
          locality: '',
          city: '',
          postalCode: '',
          latitude: position.latitude,
          longitude: position.longitude,
        );

    await SessionManager.saveDeliveryAddress(
      address: finalLocation.formattedAddress,
      title: finalLocation.title,
      latitude: finalLocation.latitude,
      longitude: finalLocation.longitude,
    );

    if (mounted) {
      appSnackBar(
        context,
        AppColor.deliveryGreen,
        'Delivery location set to ${finalLocation.title}',
      );
      widget.onLocationSelected?.call(finalLocation);
      Navigator.of(context, rootNavigator: true).pop(finalLocation);
    }
  }

  Future<void> _handleAddNewLocation() async {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.pop();

    final result = await nav.push<DeliveryLocationModel>(
      MaterialPageRoute(
        builder: (_) => const SelectLocationScreen(),
      ),
    );

    if (result != null && mounted) {
      widget.onLocationSelected?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Cross button at top center outside bottom sheet with grey circle and white 0.5 border
          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.sheetCloseGrey, // Grey circle
                border: Border.all(
                  color: AppColor.pureWhite, // White 0.5 border
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.close_rounded,
                  color: AppColor.pureWhite,
                  size: 19.sp,
                ),
              ),
            ),
          ),
          12.hS,

          // 2. Bottom Sheet Content Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.pureWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 28.h),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.w),
                        decoration: BoxDecoration(
                          color: AppColor.deliveryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppColor.deliveryGreen,
                          size: 20.sp,
                        ),
                      ),
                      10.wS,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Delivery Address',
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColor.charcoal,
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            2.hS,
                            Text(
                              'Choose your delivery location for fast service',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColor.slateGrey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  18.hS,

                  // 3. Small Row with 2 Options: [Use Current Location] & [Add New Location]
                  Row(
                    children: [
                      // Option 1: Use Current Location
                      Expanded(
                        child: _LocationOptionCard(
                          icon: Icons.my_location_rounded,
                          iconColor: AppColor.deliveryGreen,
                          iconBgColor: AppColor.deliveryGreen.withValues(alpha: 0.1),
                          title: 'Use Current Location',
                          subtitle: 'Using GPS',
                          isLoading: _isLoadingCurrentLocation,
                          onTap: _handleUseCurrentLocation,
                        ),
                      ),
                      12.wS,

                      // Option 2: Add New Address
                      Expanded(
                        child: _LocationOptionCard(
                          icon: Icons.add_location_alt_outlined,
                          iconColor: AppColor.deliveryButtonStart,
                          iconBgColor: AppColor.deliveryButtonStart.withValues(alpha: 0.1),
                          title: 'Add New Address',
                          subtitle: 'Saved & New',
                          isLoading: false,
                          onTap: _handleAddNewLocation,
                        ),
                      ),
                    ],
                  ),

                  // 4. Saved Address preview if available
                  if (_savedAddress != null && _savedAddress!.isNotEmpty) ...[
                    18.hS,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColor.deliveryInputBg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColor.deliveryInputBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColor.deliveryGreen,
                            size: 18.sp,
                          ),
                          10.wS,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _savedTitle ?? 'Saved Address',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                    color: AppColor.charcoal,
                                  ),
                                ),
                                Text(
                                  _savedAddress!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColor.slateGrey,
                                    fontSize: 11.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylish compact option card inside the bottom sheet row.
class _LocationOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _LocationOptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 98.h,
      decoration: BoxDecoration(
        color: AppColor.deliveryInputBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.deliveryInputBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row with circular icon or loading indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: iconColor,
                                ),
                              )
                            : Icon(
                                icon,
                                color: iconColor,
                                size: 17.sp,
                              ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColor.deliveryInputHint,
                      size: 12.sp,
                    ),
                  ],
                ),
                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColor.charcoal,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColor.slateGrey,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
