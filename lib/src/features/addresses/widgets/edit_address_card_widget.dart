import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_color.dart';
import '../bloc/edit_address_form/edit_address_form_bloc.dart';
import '../data/models/address_list_response.dart';

typedef OnEditAddressConfirmCallback = void Function({
  required String label,
  required String addressLine,
  String? landmark,
  required String city,
  required String pincode,
  required bool isDefault,
});

/// Bottom sheet widget displayed on the edit map screen with:
/// - Pre-filled fields from [AddressModel]
/// - Drag handle & pinned location summary
/// - Chip selection: [Home], [Office], [Other]
/// - Text form fields: Address Line, Landmark, City, Pincode
/// - Checkbox for setting as default address
/// - Gradient "Update Address" button
class EditAddressCardWidget extends StatefulWidget {
  final AddressModel initialAddress;
  final DeliveryLocationModel? location;
  final bool isLoading;
  final OnEditAddressConfirmCallback onConfirm;

  const EditAddressCardWidget({
    super.key,
    required this.initialAddress,
    required this.location,
    this.isLoading = false,
    required this.onConfirm,
  });

  @override
  State<EditAddressCardWidget> createState() => _EditAddressCardWidgetState();
}

class _EditAddressCardWidgetState extends State<EditAddressCardWidget> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedChip;
  late bool _isDefault;

  late final TextEditingController _addressLineController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _selectedChip = _formatInitialChip(widget.initialAddress.label);
    _isDefault = widget.initialAddress.isDefault;

    _addressLineController =
        TextEditingController(text: widget.initialAddress.addressLine);
    _landmarkController =
        TextEditingController(text: widget.initialAddress.landmark);
    _cityController =
        TextEditingController(text: widget.initialAddress.city);
    _pincodeController =
        TextEditingController(text: widget.initialAddress.pincode);

    // If reverse geocoded location exists and fields were empty, fill them
    if (_addressLineController.text.isEmpty && widget.location != null) {
      _populateFromLocation(widget.location);
    } else {
      _initFormBloc(widget.location);
    }
  }

  String _formatInitialChip(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'office' || lower == 'work') return 'Office';
    if (lower == 'home') return 'Home';
    if (lower == 'other') return 'Other';
    if (raw.isNotEmpty && raw != 'string') {
      return raw[0].toUpperCase() + raw.substring(1);
    }
    return 'Home';
  }

  @override
  void didUpdateWidget(covariant EditAddressCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLoc = widget.location;
    final oldLoc = oldWidget.location;

    // Only update if map coordinates changed significantly
    if (newLoc != null &&
        oldLoc != null &&
        ((newLoc.latitude - oldLoc.latitude).abs() > 0.0001 ||
            (newLoc.longitude - oldLoc.longitude).abs() > 0.0001)) {
      _populateFromLocation(newLoc);
    }
  }

  void _initFormBloc(DeliveryLocationModel? loc) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<EditAddressFormBloc>().add(
                EditAddressFormInitializeEvent(
                  publicId: widget.initialAddress.publicId.isNotEmpty
                      ? widget.initialAddress.publicId
                      : widget.initialAddress.id.toString(),
                  label: _selectedChip.toLowerCase(),
                  addressLine: _addressLineController.text,
                  landmark: _landmarkController.text,
                  city: _cityController.text,
                  pincode: _pincodeController.text,
                  isDefault: _isDefault,
                  lat: loc?.latitude.toString() ??
                      widget.initialAddress.lat.toString(),
                  lng: loc?.longitude.toString() ??
                      widget.initialAddress.lng.toString(),
                  deliveryName: widget.initialAddress.deliveryName,
                  deliveryPhone: widget.initialAddress.deliveryPhone,
                ),
              );
        } catch (_) {}
      }
    });
  }

  void _populateFromLocation(DeliveryLocationModel? loc) {
    if (loc == null) return;

    if (_addressLineController.text.trim().isEmpty) {
      _addressLineController.text = loc.addressLine.isNotEmpty
          ? loc.addressLine
          : loc.formattedAddress;
    }

    if (_landmarkController.text.trim().isEmpty && loc.locality.isNotEmpty) {
      _landmarkController.text = loc.locality;
    }

    if (_cityController.text.trim().isEmpty && loc.city.isNotEmpty) {
      _cityController.text = loc.city;
    }

    if (_pincodeController.text.trim().isEmpty) {
      if (loc.postalCode.isNotEmpty) {
        _pincodeController.text = loc.postalCode;
      } else {
        final pinMatch =
            RegExp(r'\b\d{6}\b').firstMatch(loc.formattedAddress);
        if (pinMatch != null) {
          _pincodeController.text = pinMatch.group(0)!;
        }
      }
    }

    _initFormBloc(loc);
  }

  @override
  void dispose() {
    _addressLineController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    widget.onConfirm(
      label: _selectedChip.toLowerCase(),
      addressLine: _addressLineController.text.trim(),
      landmark: _landmarkController.text.trim().isNotEmpty
          ? _landmarkController.text.trim()
          : null,
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _isDefault,
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedChip.toLowerCase() == label.toLowerCase();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChip = label;
        });
        try {
          context.read<EditAddressFormBloc>().add(
                EditAddressFormLabelChangedEvent(label.toLowerCase()),
              );
        } catch (_) {}
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.deliveryButtonStart.withValues(alpha: 0.12)
              : AppColor.deliveryInputBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColor.deliveryButtonStart
                : AppColor.deliveryInputBorder,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: isSelected
                  ? AppColor.deliveryButtonStart
                  : AppColor.slateGrey,
            ),
            6.wS,
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12.sp,
                    color: isSelected
                        ? AppColor.deliveryButtonStart
                        : AppColor.charcoal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColor.slateGrey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              10.hS,

              // 2. Pinned Address Overview Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color:
                          AppColor.deliveryButtonStart.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit_location_alt_rounded,
                        color: AppColor.deliveryButtonStart,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  10.wS,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Delivery Address',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                            color: AppColor.charcoal,
                          ),
                        ),
                        2.hS,
                        Text(
                          widget.location?.formattedAddress.isNotEmpty == true
                              ? widget.location!.formattedAddress
                              : widget.initialAddress.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11.5.sp,
                            color: AppColor.slateGrey,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              12.hS,

              // 3. Address Type Chips (Home, Office, Other)
              Row(
                children: [
                  _buildChip(
                    label: 'Home',
                    icon: Icons.home_rounded,
                  ),
                  8.wS,
                  _buildChip(
                    label: 'Office',
                    icon: Icons.business_rounded,
                  ),
                  8.wS,
                  _buildChip(
                    label: 'Other',
                    icon: Icons.location_on_rounded,
                  ),
                ],
              ),
              12.hS,

              // 4. Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Field 1: House / Building / Flat
                    _EditAddressFormField(
                      label: 'House / Building / Apartment',
                      hintText: 'e.g. Flat 402, Nageshkar Heights',
                      controller: _addressLineController,
                      prefixIcon: Icons.apartment_rounded,
                      onChanged: (val) {
                        try {
                          context.read<EditAddressFormBloc>().add(
                                EditAddressFormAddressLineChangedEvent(val),
                              );
                        } catch (_) {}
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter house/building details';
                        }
                        if (val.trim().length < 3) {
                          return 'Must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    8.hS,

                    // Field 2: Landmark / Street
                    _EditAddressFormField(
                      label: 'Landmark / Area (Optional)',
                      hintText: 'e.g. Near Rajarampuri 2nd Lane',
                      controller: _landmarkController,
                      prefixIcon: Icons.signpost_rounded,
                      onChanged: (val) {
                        try {
                          context.read<EditAddressFormBloc>().add(
                                EditAddressFormLandmarkChangedEvent(val),
                              );
                        } catch (_) {}
                      },
                    ),
                    8.hS,

                    // Field 3 & 4: City & Pincode in Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _EditAddressFormField(
                            label: 'City',
                            hintText: 'e.g. Kolhapur',
                            controller: _cityController,
                            prefixIcon: Icons.location_city_rounded,
                            onChanged: (val) {
                              try {
                                context.read<EditAddressFormBloc>().add(
                                      EditAddressFormCityChangedEvent(val),
                                    );
                              } catch (_) {}
                            },
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter city';
                              }
                              return null;
                            },
                          ),
                        ),
                        10.wS,
                        Expanded(
                          flex: 2,
                          child: _EditAddressFormField(
                            label: 'Pincode',
                            hintText: '6 digits',
                            controller: _pincodeController,
                            prefixIcon: Icons.pin_drop_rounded,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (val) {
                              try {
                                context.read<EditAddressFormBloc>().add(
                                      EditAddressFormPincodeChangedEvent(val),
                                    );
                              } catch (_) {}
                            },
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter pincode';
                              }
                              if (val.trim().length != 6) {
                                return '6 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              6.hS,

              // 5. Default Address Checkbox
              Row(
                children: [
                  SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: Checkbox(
                      value: _isDefault,
                      activeColor: AppColor.deliveryButtonStart,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      onChanged: (val) {
                        final isDef = val ?? false;
                        setState(() {
                          _isDefault = isDef;
                        });
                        try {
                          context.read<EditAddressFormBloc>().add(
                                EditAddressFormDefaultChangedEvent(isDef),
                              );
                        } catch (_) {}
                      },
                    ),
                  ),
                  8.wS,
                  GestureDetector(
                    onTap: () {
                      final isDef = !_isDefault;
                      setState(() {
                        _isDefault = isDef;
                      });
                      try {
                        context.read<EditAddressFormBloc>().add(
                              EditAddressFormDefaultChangedEvent(isDef),
                            );
                      } catch (_) {}
                    },
                    child: Text(
                      'Set as default address',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColor.charcoal,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              10.hS,

              // 6. Action Button: "Update Address"
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: Material(
                  color: AppColor.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25.r),
                    onTap: widget.isLoading ? null : _handleConfirm,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColor.deliveryButtonStart,
                            AppColor.deliveryButtonEnd,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: widget.isLoading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.pureWhite,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Update Address',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColor.pureWhite,
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  8.wS,
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColor.pureWhite,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                      ),
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

class _EditAddressFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _EditAddressFormField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColor.charcoal,
            fontWeight: FontWeight.w700,
            fontSize: 11.5.sp,
          ),
        ),
        4.hS,
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColor.charcoal,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            hintStyle: textTheme.bodySmall?.copyWith(
              color: AppColor.slateGrey.withValues(alpha: 0.65),
              fontSize: 12.sp,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColor.slateGrey,
              size: 16.sp,
            ),
            filled: true,
            fillColor: AppColor.deliveryInputBg,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColor.deliveryInputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColor.deliveryInputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColor.deliveryButtonStart,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColor.bright_red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColor.bright_red,
                width: 1.4,
              ),
            ),
            errorStyle: textTheme.bodySmall?.copyWith(
              color: AppColor.bright_red,
              fontSize: 10.sp,
            ),
          ),
        ),
      ],
    );
  }
}
