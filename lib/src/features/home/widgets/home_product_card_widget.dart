import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/home_response.dart';

/// Blinkit-like Product Card with image, variant info, price, discounted price, heart icon, and ADD button.
class HomeProductCardWidget extends StatefulWidget {
  final HomeProductItemModel product;
  final VoidCallback? onAddTap;
  final VoidCallback? onFavoriteTap;

  const HomeProductCardWidget({
    super.key,
    required this.product,
    this.onAddTap,
    this.onFavoriteTap,
  });

  @override
  State<HomeProductCardWidget> createState() => _HomeProductCardWidgetState();
}

class _HomeProductCardWidgetState extends State<HomeProductCardWidget> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final variant = widget.product.firstVariant;

    final sellingPrice = variant?.sellingPrice ?? 0;
    final actualPrice = variant?.actualPrice ?? 0;
    final hasDiscount = actualPrice > sellingPrice && actualPrice > 0;

    int discountPercent = 0;
    if (hasDiscount) {
      discountPercent = (((actualPrice - sellingPrice) / actualPrice) * 100).round();
    }

    final quantityStr = variant != null
        ? '${variant.quantity} ${variant.uomShortName.isNotEmpty ? variant.uomShortName : variant.uomName}'
        : '';

    return Container(
      width: 152.w,
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.deliveryInputBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Stack: Image, Discount Tag, and Heart Icon
          Stack(
            children: [
              // Product Image container
              Container(
                height: 105.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.deliveryInputBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                  ),
                ),
                padding: EdgeInsets.all(10.w),
                child: Center(
                  child: widget.product.productImage != null &&
                          widget.product.productImage!.isNotEmpty
                      ? Image.network(
                          widget.product.productImage!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.deliveryButtonStart,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColor.slateGrey,
                            size: 36.sp,
                          ),
                        )
                      : Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColor.slateGrey,
                          size: 36.sp,
                        ),
                ),
              ),

              // Discount Tag (Top-Left)
              if (hasDiscount && discountPercent > 0)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColor.deliveryButtonStart,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '$discountPercent% OFF',
                      style: TextStyle(
                        color: AppColor.pureWhite,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

              // Heart (Wishlist) Icon (Top-Right)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    widget.onFavoriteTap?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppColor.pureWhite.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite
                          ? AppColor.bright_red
                          : AppColor.slateGrey,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content section (Padding)
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variant quantity pill
                if (quantityStr.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColor.deliveryInputBg,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      quantityStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColor.slateGrey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  4.hS,
                ],

                // Product Name
                Text(
                  widget.product.productName.isNotEmpty
                      ? widget.product.productName
                      : widget.product.productShortName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColor.charcoal,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                8.hS,

                // Price Row and ADD Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹$sellingPrice',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColor.charcoal,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (hasDiscount) ...[
                            2.hS,
                            Text(
                              '₹$actualPrice',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColor.slateGrey,
                                fontSize: 10.5.sp,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    4.wS,

                    // Blinkit-style ADD Button
                    GestureDetector(
                      onTap: widget.onAddTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.deliveryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColor.deliveryGreen,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ADD',
                              style: TextStyle(
                                color: AppColor.deliveryGreen,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            2.wS,
                            Icon(
                              Icons.add_rounded,
                              color: AppColor.deliveryGreen,
                              size: 14.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
