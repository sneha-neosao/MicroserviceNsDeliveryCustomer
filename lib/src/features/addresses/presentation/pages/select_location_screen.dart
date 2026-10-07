import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../widgets/map_address_card_widget.dart';
import '../../widgets/map_my_location_button_widget.dart';
import '../../widgets/map_pin_widget.dart';
import '../../widgets/map_search_bar_widget.dart';

/// Full interactive Google Map screen for picking or confirming delivery location.
class SelectLocationScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const SelectLocationScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  // Default coordinate (Pune, Maharashtra)
  static const LatLng _defaultLocation = LatLng(18.5204303, 73.8567437);

  GoogleMapController? _mapController;
  LatLng _currentCenter = _defaultLocation;
  DeliveryLocationModel? _currentLocation;
  bool _isMoving = false;
  bool _isGeocoding = false;
  bool _isLocatingUser = false;
  Timer? _debounceTimer;
  int _latestGeocodeRequestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _currentCenter = LatLng(widget.initialLat!, widget.initialLng!);
    }
    _initInitialLocation();
  }

  Future<void> _initInitialLocation() async {
    // If coordinates were explicitly passed, reverse geocode directly
    if (widget.initialLat != null && widget.initialLng != null) {
      final target = LatLng(widget.initialLat!, widget.initialLng!);
      _currentCenter = target;
      _animateToPosition(target, zoom: 17.0);
      await _fetchAddressForCoordinates(target);
      return;
    }

    // Prioritize live current GPS location when opening the map screen
    await _locateUser();
  }

  Future<void> _locateUser() async {
    if (_isLocatingUser) return;
    setState(() {
      _isLocatingUser = true;
      _isGeocoding = true;
    });

    try {
      // 1. Initial quick center using last known position ONLY if map is uninitialized
      if (_currentLocation == null) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null && mounted) {
            final target = LatLng(lastKnown.latitude, lastKnown.longitude);
            _currentCenter = target;
            _animateToPosition(target, zoom: 16.5);
          }
        } catch (_) {}
      }

      // 2. Fetch fresh live current GPS position with high accuracy
      final position = await LocationService.getCurrentPosition();
      if (position != null && mounted) {
        final target = LatLng(position.latitude, position.longitude);
        _currentCenter = target;
        _animateToPosition(target, zoom: 17.5);
        await _fetchAddressForCoordinates(target);
      } else if (mounted) {
        // Fallback if GPS not acquired: check saved session coordinates or default
        if (_currentLocation == null) {
          final savedCoords = await SessionManager.getDeliveryCoordinates();
          if (savedCoords != null) {
            final target = LatLng(savedCoords['lat']!, savedCoords['lng']!);
            _currentCenter = target;
            _animateToPosition(target, zoom: 16.5);
            await _fetchAddressForCoordinates(target);
          } else {
            await _fetchAddressForCoordinates(_currentCenter);
          }
        }
        if (mounted) {
          appSnackBar(
            context,
            AppColor.bright_red,
            'Please ensure GPS/Location is enabled for accurate live address.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        appSnackBar(
          context,
          AppColor.bright_red,
          'Error acquiring current location: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingUser = false;
        });
      }
    }
  }

  void _animateToPosition(LatLng target, {double zoom = 17.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _fetchAddressForCoordinates(LatLng coords) async {
    final requestId = ++_latestGeocodeRequestId;
    setState(() {
      _isGeocoding = true;
    });

    final result = await LocationService.getAddressFromCoordinates(
      coords.latitude,
      coords.longitude,
    );

    if (!mounted || requestId != _latestGeocodeRequestId) {
      // Discard stale or superseded geocode responses
      return;
    }

    setState(() {
      _currentLocation = result ??
          DeliveryLocationModel(
            formattedAddress:
                '${coords.latitude.toStringAsFixed(5)}, ${coords.longitude.toStringAsFixed(5)}',
            title: 'Pinned Location',
            addressLine: 'Pinned Location',
            locality: '',
            city: '',
            postalCode: '',
            latitude: coords.latitude,
            longitude: coords.longitude,
          );
      _isGeocoding = false;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;
    if (!_isMoving) {
      setState(() {
        _isMoving = true;
      });
    }
  }

  void _onCameraIdle() {
    if (_isMoving) {
      setState(() {
        _isMoving = false;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchAddressForCoordinates(_currentCenter);
    });
  }

  void _onLocationSelectedFromSearch(DeliveryLocationModel selected) {
    final target = LatLng(selected.latitude, selected.longitude);
    _currentCenter = target;
    _currentLocation = selected;
    _animateToPosition(target, zoom: 17.5);
    setState(() {});
  }

  Future<void> _onConfirmLocation({
    required String label,
    required String addressLine,
    String? landmark,
    required String city,
    required String pincode,
    required bool isDefault,
  }) async {
    final fullFormattedAddress = [
      addressLine.trim(),
      if (landmark != null && landmark.trim().isNotEmpty) landmark.trim(),
      city.trim(),
      pincode.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

    final confirmedLocation = DeliveryLocationModel(
      formattedAddress: fullFormattedAddress,
      title: label,
      addressLine: addressLine.trim(),
      locality: landmark?.trim() ?? '',
      city: city.trim(),
      postalCode: pincode.trim(),
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
    );

    await SessionManager.saveDeliveryAddress(
      address: confirmedLocation.formattedAddress,
      title: confirmedLocation.title,
      latitude: confirmedLocation.latitude,
      longitude: confirmedLocation.longitude,
    );

    if (mounted) {
      appSnackBar(
        context,
        AppColor.deliveryGreen,
        'Address saved for $label',
      );
      Navigator.of(context).pop(confirmedLocation);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // 1. Google Map View
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentCenter,
                zoom: 16.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _animateToPosition(_currentCenter);
              },
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
            ),

            // 2. Center Target Delivery Pin
            MapPinWidget(isMoving: _isMoving),

            // 3. Top Floating Search Bar & Back Button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: MapSearchBarWidget(
                  onBack: () => Navigator.of(context).pop(),
                  onLocationSelected: _onLocationSelectedFromSearch,
                ),
              ),
            ),

            // 4. Floating "Locate Me" GPS Button below search bar
            Positioned(
              right: 18.w,
              top: 76.h,
              child: MapMyLocationButtonWidget(
                isLoading: _isLocatingUser,
                onTap: _locateUser,
              ),
            ),

            // 5. Bottom Location Detail Sheet with Chips, Form Fields and Confirm Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapAddressCardWidget(
                location: _currentLocation,
                isLoading: _isGeocoding || _isMoving,
                onConfirm: _onConfirmLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
