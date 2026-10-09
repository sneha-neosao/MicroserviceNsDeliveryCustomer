import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/address_list_response.dart';

/// Custom alert dialog for confirming address deletion.
class AddressDeleteDialogWidget extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onConfirm;

  const AddressDeleteDialogWidget({
    super.key,
    required this.address,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AddressModel address,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddressDeleteDialogWidget(
        address: address,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final label = address.label.isNotEmpty && address.label.toLowerCase() != 'string'
        ? address.label[0].toUpperCase() + address.label.substring(1)
        : 'this';

    return Dialog(
      backgroundColor: AppColor.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Warning / Trash Icon
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: AppColor.bright_red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColor.bright_red,
                size: 28.sp,
              ),
            ),
            16.hS,

            // Dialog Title
            Text(
              'Delete Address',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColor.charcoal,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            8.hS,

            // Description text with multi-line safety
            Text(
              'Are you sure you want to delete $label address? This action cannot be undone.',
              textAlign: TextAlign.center,
              softWrap: true,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColor.slateGrey,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            20.hS,

            // Action Buttons Row: Cancel and Delete
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColor.deliveryInputBorder,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColor.charcoal,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                12.wS,

                // Delete Confirm Button
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.bright_red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColor.pureWhite,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
