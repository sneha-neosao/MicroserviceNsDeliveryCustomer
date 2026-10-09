import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/edit_address/edit_address_bloc.dart';
import '../../bloc/edit_address_form/edit_address_form_bloc.dart';
import '../../data/models/address_list_response.dart';
import '../../domain/usecases/edit_address_usecase.dart';
import '../../widgets/edit_address_card_widget.dart';
import '../../widgets/map_my_location_button_widget.dart';
import '../../widgets/map_pin_widget.dart';
import '../../widgets/map_search_bar_widget.dart';

/// Full interactive Google Map screen for editing an existing delivery address.
/// Pre-fills address fields and focuses marker on the address coordinates.
class EditAddressScreen extends StatefulWidget {
  final AddressModel address;

  const EditAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditAddressBloc>(
          create: (_) => getIt<EditAddressBloc>(),
        ),
        BlocProvider<EditAddressFormBloc>(
          create: (_) => getIt<EditAddressFormBloc>(),
        ),
      ],
      child: _EditAddressScreenContent(
        address: widget.address,
      ),
    );
  }
}

class _EditAddressScreenContent extends StatefulWidget {
  final AddressModel address;

  const _EditAddressScreenContent({
    required this.address,
  });

  @override
  State<_EditAddressScreenContent> createState() =>
      _EditAddressScreenContentState();
}

class _EditAddressScreenContentState
    extends State<_EditAddressScreenContent> {
  GoogleMapController? _mapController;
  late LatLng _currentCenter;
  DeliveryLocationModel? _currentLocation;
  bool _isMoving = false;
  bool _isGeocoding = false;
  bool _isLocatingUser = false;
  Timer? _debounceTimer;
  int _latestGeocodeRequestId = 0;

  @override
  void initState() {
    super.initState();
    final lat = widget.address.lat != 0.0 ? widget.address.lat : 18.5204303;
    final lng = widget.address.lng != 0.0 ? widget.address.lng : 73.8567437;
    _currentCenter = LatLng(lat, lng);

    _currentLocation = DeliveryLocationModel(
      formattedAddress: widget.address.fullAddress,
      title: widget.address.label,
      addressLine: widget.address.addressLine,
      locality: widget.address.landmark,
      city: widget.address.city,
      postalCode: widget.address.pincode,
      latitude: lat,
      longitude: lng,
    );

    // Initial reverse geocode if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToPosition(_currentCenter, zoom: 17.5);
    });
  }

  Future<void> _locateUser() async {
    if (_isLocatingUser) return;
    setState(() {
      _isLocatingUser = true;
      _isGeocoding = true;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null && mounted) {
        final target = LatLng(position.latitude, position.longitude);
        _currentCenter = target;
        _animateToPosition(target, zoom: 17.5);
        await _fetchAddressForCoordinates(target);
      } else if (mounted) {
        appSnackBar(
          context,
          AppColor.bright_red,
          'Please ensure GPS/Location is enabled for accurate live address.',
        );
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
      return;
    }

    setState(() {
      _currentLocation = result ??
          DeliveryLocationModel(
            formattedAddress:
                '${coords.latitude.toStringAsFixed(5)}, ${coords.longitude.toStringAsFixed(5)}',
            title: widget.address.label.isNotEmpty
                ? widget.address.label
                : 'Pinned Location',
            addressLine: widget.address.addressLine,
            locality: widget.address.landmark,
            city: widget.address.city,
            postalCode: widget.address.pincode,
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
    String deliveryName = widget.address.deliveryName.trim();
    String deliveryPhone = widget.address.deliveryPhone.trim();

    if (deliveryName.isEmpty) {
      deliveryName = (await SessionManager.getUserName())?.trim() ?? '';
    }
    if (deliveryPhone.isEmpty) {
      deliveryPhone =
          (await SessionManager.getUserMobileNumber())?.trim() ?? '';
    }

    if (deliveryName.isEmpty || deliveryPhone.isEmpty) {
      final customer = await SessionManager.getCustomerData();
      if (deliveryName.isEmpty && customer?.name != null) {
        deliveryName = customer!.name.trim();
      }
      if (deliveryPhone.isEmpty && customer?.contact != null) {
        deliveryPhone = customer!.contact.trim();
      }
    }

    if (deliveryName.isEmpty) deliveryName = 'Customer';
    if (deliveryPhone.isEmpty) deliveryPhone = '0000000000';

    final publicId = widget.address.publicId.isNotEmpty
        ? widget.address.publicId
        : widget.address.id.toString();

    final params = EditAddressParams(
      publicId: publicId,
      label: label.toLowerCase().trim(),
      deliveryName: deliveryName,
      deliveryPhone: deliveryPhone,
      addressLine: addressLine.trim(),
      landmark: landmark?.trim(),
      city: city.trim(),
      pincode: pincode.trim(),
      lat: _currentCenter.latitude,
      lng: _currentCenter.longitude,
      isDefault: isDefault,
    );

    if (mounted) {
      context.read<EditAddressBloc>().add(EditAddressSubmitEvent(params));
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
    return BlocConsumer<EditAddressBloc, EditAddressState>(
      listener: (context, state) async {
        if (state is EditAddressFailureState) {
          appSnackBar(context, AppColor.bright_red, state.message);
        } else if (state is EditAddressSuccessState) {
          final data = state.data.data;
          DeliveryLocationModel? updatedLocation;

          if (data != null) {
            final fullAddr = [
              data.addressLine,
              if (data.landmark.isNotEmpty) data.landmark,
              data.city,
              data.pincode,
            ].where((e) => e.isNotEmpty).join(', ');

            await SessionManager.saveDeliveryAddress(
              address: fullAddr,
              title: data.label,
              latitude: data.lat,
              longitude: data.lng,
            );

            updatedLocation = DeliveryLocationModel(
              formattedAddress: fullAddr,
              title: data.label.isNotEmpty ? data.label : 'Delivery Address',
              locality: '',
              city: data.city,
              postalCode: data.pincode,
              latitude:
                  data.lat != 0.0 ? data.lat : _currentCenter.latitude,
              longitude:
                  data.lng != 0.0 ? data.lng : _currentCenter.longitude,
            );
          }

          if (context.mounted) {
            appSnackBar(
              context,
              AppColor.deliveryGreen,
              state.data.message.isNotEmpty
                  ? state.data.message
                  : 'Address updated successfully',
            );
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(updatedLocation);
            } else {
              Navigator.of(context).pop();
            }
          }
        }
      },
      builder: (context, state) {
        final isSubmitting = state is EditAddressLoadingState;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: [
                // 1. Google Map View centered on existing coordinates
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentCenter,
                    zoom: 17.5,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _animateToPosition(_currentCenter, zoom: 17.5);
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 10.h),
                    child: MapSearchBarWidget(
                      onBack: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
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

                // 5. Bottom Location Detail Sheet with pre-filled inputs
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: EditAddressCardWidget(
                    initialAddress: widget.address,
                    location: _currentLocation,
                    isLoading: isSubmitting || _isGeocoding || _isMoving,
                    onConfirm: _onConfirmLocation,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
