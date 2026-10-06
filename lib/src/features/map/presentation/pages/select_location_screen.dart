import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _currentCenter = LatLng(widget.initialLat!, widget.initialLng!);
    }
    _initInitialLocation();
  }

  Future<void> _initInitialLocation() async {
    // If coordinates were passed, reverse geocode directly
    if (widget.initialLat != null && widget.initialLng != null) {
      await _fetchAddressForCoordinates(_currentCenter);
      return;
    }

    // Check saved coordinates in session
    final savedCoords = await SessionManager.getDeliveryCoordinates();
    if (savedCoords != null) {
      final lat = savedCoords['lat']!;
      final lng = savedCoords['lng']!;
      _currentCenter = LatLng(lat, lng);
      _animateToPosition(_currentCenter);
      await _fetchAddressForCoordinates(_currentCenter);
      return;
    }

    // Fallback: fetch current GPS position
    await _locateUser();
  }

  Future<void> _locateUser() async {
    if (_isLocatingUser) return;
    setState(() {
      _isLocatingUser = true;
    });

    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final target = LatLng(position.latitude, position.longitude);
      _currentCenter = target;
      _animateToPosition(target);
      await _fetchAddressForCoordinates(target);
    } else {
      await _fetchAddressForCoordinates(_currentCenter);
    }

    if (mounted) {
      setState(() {
        _isLocatingUser = false;
      });
    }
  }

  void _animateToPosition(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 16.5,
        ),
      ),
    );
  }

  Future<void> _fetchAddressForCoordinates(LatLng coords) async {
    setState(() {
      _isGeocoding = true;
    });

    final result = await LocationService.getAddressFromCoordinates(
      coords.latitude,
      coords.longitude,
    );

    if (mounted) {
      setState(() {
        _currentLocation = result ??
            DeliveryLocationModel(
              formattedAddress: '${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}',
              title: 'Pinned Location',
              locality: '',
              city: '',
              postalCode: '',
              latitude: coords.latitude,
              longitude: coords.longitude,
            );
        _isGeocoding = false;
      });
    }
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
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchAddressForCoordinates(_currentCenter);
    });
  }

  void _onLocationSelectedFromSearch(DeliveryLocationModel selected) {
    final target = LatLng(selected.latitude, selected.longitude);
    _currentCenter = target;
    _currentLocation = selected;
    _animateToPosition(target);
    setState(() {});
  }

  Future<void> _onConfirmLocation() async {
    if (_currentLocation == null) return;

    await SessionManager.saveDeliveryAddress(
      address: _currentLocation!.formattedAddress,
      title: _currentLocation!.title,
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
    );

    if (mounted) {
      appSnackBar(
        context,
        AppColor.deliveryGreen,
        'Delivery location set to ${_currentLocation!.title}',
      );
      Navigator.of(context).pop(_currentLocation);
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
        backgroundColor: AppColor.screenBg,
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

            // 4. Floating "Locate Me" GPS Button
            Positioned(
              right: 18.w,
              bottom: 210.h,
              child: MapMyLocationButtonWidget(
                isLoading: _isLocatingUser,
                onTap: _locateUser,
              ),
            ),

            // 5. Bottom Location Detail Card with Confirm Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapAddressCardWidget(
                location: _currentLocation,
                isLoading: _isGeocoding,
                onConfirm: _onConfirmLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
