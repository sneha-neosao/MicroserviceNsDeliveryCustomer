import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_color.dart';

typedef OnAddressConfirmCallback = void Function({
  required String label,
  required String addressLine,
  String? landmark,
  required String city,
  required String pincode,
  required bool isDefault,
});

/// Bottom sheet widget displayed on the map screen with:
/// - Drag handle & pinned location summary
/// - Chip selection: [Home], [Office], [Other]
/// - Text form fields: Address Line, Landmark, City, Pincode
/// - Checkbox for setting as default address
/// - Gradient "Confirm" button
class MapAddressCardWidget extends StatefulWidget {
  final DeliveryLocationModel? location;
  final bool isLoading;
  final OnAddressConfirmCallback onConfirm;

  const MapAddressCardWidget({
    super.key,
    required this.location,
    this.isLoading = false,
    required this.onConfirm,
  });

  @override
  State<MapAddressCardWidget> createState() => _MapAddressCardWidgetState();
}

class _MapAddressCardWidgetState extends State<MapAddressCardWidget> {
  final _formKey = GlobalKey<FormState>();

  String _selectedChip = 'Home';
  bool _isDefault = false;

  late final TextEditingController _addressLineController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _addressLineController = TextEditingController();
    _landmarkController = TextEditingController();
    _cityController = TextEditingController();
    _pincodeController = TextEditingController();

    _populateFromLocation(widget.location);
  }

  @override
  void didUpdateWidget(covariant MapAddressCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLoc = widget.location;
    final oldLoc = oldWidget.location;
    if (newLoc != null &&
        (oldLoc == null ||
            newLoc.latitude != oldLoc.latitude ||
            newLoc.longitude != oldLoc.longitude ||
            newLoc.formattedAddress != oldLoc.formattedAddress ||
            newLoc.addressLine != oldLoc.addressLine ||
            newLoc.locality != oldLoc.locality ||
            newLoc.city != oldLoc.city ||
            newLoc.postalCode != oldLoc.postalCode)) {
      _populateFromLocation(newLoc);
    }
  }

  void _populateFromLocation(DeliveryLocationModel? loc) {
    if (loc == null) return;

    // 1. Address Line
    final addressLine = loc.addressLine.isNotEmpty
        ? loc.addressLine
        : _extractAddressLineFallback(loc);
    _addressLineController.text = addressLine;

    // 2. Landmark / Locality
    _landmarkController.text = loc.locality;

    // 3. City
    _cityController.text = loc.city;

    // 4. Pincode (with 6-digit regex fallback)
    if (loc.postalCode.isNotEmpty) {
      _pincodeController.text = loc.postalCode;
    } else {
      final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(loc.formattedAddress);
      if (pinMatch != null) {
        _pincodeController.text = pinMatch.group(0)!;
      } else {
        _pincodeController.clear();
      }
    }
  }

  String _extractAddressLineFallback(DeliveryLocationModel loc) {
    if (loc.addressLine.isNotEmpty) return loc.addressLine;
    if (loc.formattedAddress.isEmpty) return loc.title;

    final parts = loc.formattedAddress.split(',');
    if (parts.length <= 1) return loc.formattedAddress.trim();

    final filtered = parts.where((part) {
      final trimmed = part.trim().toLowerCase();
      if (loc.city.isNotEmpty && trimmed == loc.city.toLowerCase()) return false;
      if (loc.postalCode.isNotEmpty && trimmed.contains(loc.postalCode)) return false;
      if (trimmed == 'india') return false;
      return true;
    }).toList();

    if (filtered.isNotEmpty) {
      return filtered.take(2).map((e) => e.trim()).join(', ');
    }
    return parts.first.trim();
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
      label: _selectedChip,
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
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected
                  ? AppColor.deliveryButtonStart
                  : AppColor.slateGrey,
            ),
            6.wS,
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColor.deliveryButtonStart
                        : AppColor.charcoal,
                    fontSize: 12.5.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = bottomInset > 0
        ? screenHeight * 0.70
        : screenHeight * 0.38;

    return Container(
      width: double.infinity,
      height: sheetHeight,
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              // Top drag indicator
              Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColor.gray.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),

              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip selection: [Home], [Office], [Other]
                        Text(
                          'Save Address As',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColor.charcoal,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        8.hS,
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
                        14.hS,

                        // 3. Address Line field
                        _AddressFormField(
                          label: 'House / Building No., Lane & Street',
                          hint: 'Flat/House No., Building, Lane & Street',
                          controller: _addressLineController,
                          prefixIcon: Icons.home_outlined,
                          isRequired: true,
                        ),
                        10.hS,

                        // 4. Landmark field
                        _AddressFormField(
                          label: 'Area & Landmark',
                          hint: 'Colony, Area, Sector or nearby landmark',
                          controller: _landmarkController,
                          prefixIcon: Icons.near_me_outlined,
                          isRequired: false,
                        ),
                        10.hS,

                        // 5. City and Pincode in a Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _AddressFormField(
                                label: 'City',
                                hint: 'City name',
                                controller: _cityController,
                                prefixIcon: Icons.location_city_outlined,
                                isRequired: true,
                              ),
                            ),
                            10.wS,
                            Expanded(
                              flex: 2,
                              child: _AddressFormField(
                                label: 'Pincode',
                                hint: '6-digit PIN',
                                controller: _pincodeController,
                                prefixIcon: Icons.pin_drop_outlined,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        12.hS,

                        // 6. Checkbox: Set as default
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
                                side: const BorderSide(
                                  color: AppColor.deliveryInputBorder,
                                  width: 1.5,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _isDefault = val ?? false;
                                  });
                                },
                              ),
                            ),
                            10.wS,
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _isDefault = !_isDefault;
                                });
                              },
                              child: Text(
                                'Set as default address',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColor.charcoal,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.hS,

                        // 7. Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: widget.isLoading ? null : _handleConfirm,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              elevation: 3,
                              shadowColor: AppColor.deliveryButtonStart
                                  .withValues(alpha: 0.35),
                            ),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Confirm',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: AppColor.pureWhite,
                                        fontSize: 15.sp,
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
                      ],
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

class _AddressFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isRequired;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _AddressFormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColor.charcoal,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColor.bright_red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        4.hS,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColor.charcoal,
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
          ),
          validator: (val) {
            if (isRequired && (val == null || val.trim().isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: textTheme.bodySmall?.copyWith(
              color: AppColor.deliveryInputHint,
              fontSize: 12.sp,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColor.deliveryButtonStart,
              size: 17.sp,
            ),
            filled: true,
            fillColor: AppColor.deliveryInputBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 11.h,
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              color: AppColor.bright_red,
              height: 1.2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: AppColor.deliveryInputBorder,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: AppColor.deliveryInputBorder,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: AppColor.deliveryButtonStart,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: AppColor.bright_red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: AppColor.bright_red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
