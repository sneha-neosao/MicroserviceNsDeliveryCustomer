import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/home_response.dart';

/// Widget presenting the top 2 Main Categories in a row (e.g. Mart & Food).
class HomeMainCategoriesWidget extends StatelessWidget {
  final List<MainCategoryModel> categories;
  final ValueChanged<MainCategoryModel>? onCategoryTap;

  const HomeMainCategoriesWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    // Show up to 2 categories side-by-side in a row
    final itemsToShow = categories.take(2).toList();

    return Row(
      children: [
        for (int i = 0; i < itemsToShow.length; i++) ...[
          if (i > 0) 12.wS,
          Expanded(
            child: _MainCategoryCard(
              category: itemsToShow[i],
              onTap: () => onCategoryTap?.call(itemsToShow[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _MainCategoryCard extends StatelessWidget {
  final MainCategoryModel category;
  final VoidCallback onTap;

  const _MainCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFood = category.slug.toLowerCase().contains('food');

    final gradientColors = isFood
        ? [
            AppColor.deliveryButtonStart.withValues(alpha: 0.08),
            AppColor.deliveryButtonEnd.withValues(alpha: 0.04),
          ]
        : [
            AppColor.deliveryGreen.withValues(alpha: 0.08),
            AppColor.deliveryGreen.withValues(alpha: 0.03),
          ];

    final accentColor =
        isFood ? AppColor.deliveryButtonStart : AppColor.deliveryGreen;

    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Left Column: Name & Description
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.mainCategoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColor.charcoal,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      4.hS,
                      Text(
                        category.shortDescription.isNotEmpty
                            ? category.shortDescription
                            : (isFood ? 'Fast Food Delivery' : 'Groceries & Essentials'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColor.slateGrey,
                          fontSize: 11.sp,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                8.wS,

                // Right Image / Icon
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 58.w,
                      height: 58.w,
                      decoration: BoxDecoration(
                        color: AppColor.pureWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: category.mainCategoryImage != null &&
                                category.mainCategoryImage!.isNotEmpty
                            ? Image.network(
                                category.mainCategoryImage!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: accentColor,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  isFood
                                      ? Icons.fastfood_rounded
                                      : Icons.shopping_basket_rounded,
                                  color: accentColor,
                                  size: 26.sp,
                                ),
                              )
                            : Icon(
                                isFood
                                    ? Icons.fastfood_rounded
                                    : Icons.shopping_basket_rounded,
                                color: accentColor,
                                size: 26.sp,
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
    );
  }
}
