import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/address_list/address_list_bloc.dart';
import '../../bloc/delete_address/delete_address_bloc.dart';
import '../../data/models/address_list_response.dart';
import '../../widgets/address_card_widget.dart';
import '../../widgets/address_delete_dialog_widget.dart';
import '../../widgets/address_empty_widget.dart';
import '../../widgets/address_header_widget.dart';
import '../../widgets/address_location_options_widget.dart';
import '../../widgets/address_shimmer_widget.dart';
import '../../widgets/add_new_address_button_widget.dart';
import 'select_location_screen.dart';

/// Screen displaying the user's saved address list with:
/// - Clean Architecture dual/multi BLoC injection
/// - Top quick action cards: [Use Current Location] and [Add New Location]
/// - API execution on initState via [AddressListGetEvent]
/// - Pull-to-refresh capability
/// - Interactive address selection updating [SessionManager]
/// - Action to add a new address via [SelectLocationScreen]
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadInitialSelectedId();
  }

  Future<void> _loadInitialSelectedId() async {
    final id = await SessionManager.getSelectedAddressId();
    if (mounted && id != null) {
      setState(() {
        _selectedAddressId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddressListBloc>(
          create: (_) => getIt<AddressListBloc>()..add(AddressListGetEvent()),
        ),
        BlocProvider<DeleteAddressBloc>(
          create: (_) => getIt<DeleteAddressBloc>(),
        ),
      ],
      child: _AddressScreenContent(
        selectedAddressId: _selectedAddressId,
        onAddressSelected: (id) {
          setState(() {
            _selectedAddressId = id;
          });
        },
      ),
    );
  }
}

class _AddressScreenContent extends StatefulWidget {
  final int? selectedAddressId;
  final ValueChanged<int> onAddressSelected;

  const _AddressScreenContent({
    required this.selectedAddressId,
    required this.onAddressSelected,
  });

  @override
  State<_AddressScreenContent> createState() => _AddressScreenContentState();
}

class _AddressScreenContentState extends State<_AddressScreenContent> {
  int? _currentSelectedId;
  bool _isLoadingCurrentLocation = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedId = widget.selectedAddressId;
    _loadSavedSelectedId();
  }

  @override
  void didUpdateWidget(covariant _AddressScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddressId != oldWidget.selectedAddressId &&
        widget.selectedAddressId != null) {
      setState(() {
        _currentSelectedId = widget.selectedAddressId;
      });
    }
  }

  Future<void> _loadSavedSelectedId() async {
    final id = await SessionManager.getSelectedAddressId();
    if (mounted && id != null && _currentSelectedId == null) {
      setState(() {
        _currentSelectedId = id;
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
      context.pop(finalLocation);
    }
  }

  Future<void> _handleAddressTap(AddressModel address) async {
    setState(() {
      _currentSelectedId = address.id;
    });
    widget.onAddressSelected(address.id);

    final title = address.label.isNotEmpty && address.label.toLowerCase() != 'string'
        ? address.label[0].toUpperCase() + address.label.substring(1)
        : address.deliveryName.isNotEmpty
            ? address.deliveryName
            : 'Delivery Address';

    final fullAddress = address.fullAddress.isNotEmpty
        ? address.fullAddress
        : address.addressLine;

    await SessionManager.saveDeliveryAddress(
      address: fullAddress,
      title: title,
      latitude: address.lat,
      longitude: address.lng,
      addressId: address.id,
    );
    await SessionManager.saveSelectedAddressId(address.id);

    if (mounted) {
      // Brief 250ms feedback delay so the user visibly sees the orange border before closing
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        context.pop(address);
      }
    }
  }

  Future<void> _handleAddNewAddress() async {
    final result = await context.pushNamed<DeliveryLocationModel>(
      AppRoute.selectLocation.name,
    );

    if (result != null && mounted) {
      // Re-fetch addresses list when returning from new address creation
      context.read<AddressListBloc>().add(AddressListGetEvent());
    }
  }

  Future<void> _handleEditAddress(AddressModel address) async {
    final result = await context.pushNamed<DeliveryLocationModel>(
      AppRoute.editAddress.name,
      extra: address,
    );

    if (result != null && mounted) {
      context.read<AddressListBloc>().add(AddressListGetEvent());
    }
  }

  Future<void> _handleDeleteAddress(AddressModel address) async {
    if (_isDeleting) return;

    await AddressDeleteDialogWidget.show(
      context,
      address: address,
      onConfirm: () {
        context.read<DeleteAddressBloc>().add(
              DeleteAddressSubmitEvent(publicId: address.publicId),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocListener<DeleteAddressBloc, DeleteAddressState>(
        listener: (context, deleteState) {
          if (deleteState is DeleteAddressLoadingState) {
            setState(() {
              _isDeleting = true;
            });
          } else if (deleteState is DeleteAddressSuccessState) {
            setState(() {
              _isDeleting = false;
            });
            appSnackBar(
              context,
              AppColor.deliveryGreen,
              deleteState.data.message.isNotEmpty
                  ? deleteState.data.message
                  : 'Address deleted successfully',
            );
            // Refresh address list API and UI
            context.read<AddressListBloc>().add(AddressListGetEvent());
          } else if (deleteState is DeleteAddressFailureState) {
            setState(() {
              _isDeleting = false;
            });
            appSnackBar(
              context,
              AppColor.bright_red,
              deleteState.message,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: BlocConsumer<AddressListBloc, AddressListState>(
            listener: (context, state) {
              if (state is AddressListFailureState) {
                appSnackBar(
                  context,
                  AppColor.bright_red,
                  state.message,
                );
              }
            },
            builder: (context, state) {
              final addresses = state is AddressListSuccessState
                  ? (state.data.data?.addresses ?? [])
                  : <AddressModel>[];

              final total = state is AddressListSuccessState
                  ? (state.data.data?.total ?? addresses.length)
                  : 0;

              final isLoading = state is AddressListLoadingState;

              return Column(
                children: [
                  if (_isDeleting)
                    const LinearProgressIndicator(
                      color: AppColor.deliveryButtonStart,
                      backgroundColor: AppColor.deliveryInputBg,
                      minHeight: 2.5,
                    ),

                  // 1. Top Header with title, subtitle and count
                  AddressHeaderWidget(
                    totalCount: total,
                  ),

                12.hS,

                // 2. 2 Quick Options: [Use Current Location] and [Add New Location]
                AddressLocationOptionsWidget(
                  isLoadingCurrentLocation: _isLoadingCurrentLocation,
                  onUseCurrentLocation: _handleUseCurrentLocation,
                  onAddNewLocation: _handleAddNewAddress,
                ),
                16.hS,

                // Section Title: SAVED ADDRESSES
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SAVED ADDRESSES',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.slateGrey,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                    ),
                  ),
                ),
                6.hS,

                // 3. Body List / Shimmer / Empty State
                Expanded(
                  child: isLoading
                      ? const AddressShimmerWidget()
                      : addresses.isEmpty
                          ? AddressEmptyWidget(
                              onAddNew: _handleAddNewAddress,
                            )
                          : RefreshIndicator(
                              color: AppColor.deliveryButtonStart,
                              onRefresh: () async {
                                context
                                    .read<AddressListBloc>()
                                    .add(AddressListGetEvent());
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  8.h,
                                  16.w,
                                  100.h,
                                ),
                                itemCount: addresses.length,
                                itemBuilder: (context, index) {
                                  final item = addresses[index];
                                  final isSelected =
                                      _currentSelectedId != null
                                          ? _currentSelectedId == item.id
                                          : item.isDefault;

                                  return AddressCardWidget(
                                    address: item,
                                    isSelected: isSelected,
                                    onTap: () => _handleAddressTap(item),
                                    onEdit: () => _handleEditAddress(item),
                                    onDelete: () => _handleDeleteAddress(item),
                                  );
                                },
                              ),
                            ),
                ),

                // 4. Bottom Sticky Action Button "+ Add New Address"
                AddNewAddressButtonWidget(
                  onTap: _handleAddNewAddress,
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}
