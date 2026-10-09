import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/home_response.dart';

/// Section widget for Category List type:
/// - Section title above
/// - Small square cards with image, and category name below the card
class HomeCategoryListSectionWidget extends StatelessWidget {
  final HomeSectionModel section;
  final ValueChanged<HomeCategoryItemModel>? onCategoryTap;

  const HomeCategoryListSectionWidget({
    super.key,
    required this.section,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = section.categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        if (section.title.isNotEmpty && section.title.toLowerCase() != 'string') ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              section.title,
              style: textTheme.titleMedium?.copyWith(
                color: AppColor.charcoal,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          10.hS,
        ],

        // Horizontal list of small square cards
        SizedBox(
          height: 104.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, _) => 12.wS,
            itemBuilder: (context, index) {
              final item = categories[index];
              return _CategoryItemCard(
                category: item,
                onTap: () => onCategoryTap?.call(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItemCard extends StatelessWidget {
  final HomeCategoryItemModel category;
  final VoidCallback onTap;

  const _CategoryItemCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72.w,
        child: Column(
          children: [
            // Small Square Card with Image
            Container(
              width: 68.w,
              height: 68.w,
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
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(8.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: category.categoryImage != null &&
                        category.categoryImage!.isNotEmpty
                    ? Image.network(
                        category.categoryImage!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.deliveryButtonStart,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.category_rounded,
                          color: AppColor.deliveryButtonStart,
                          size: 26.sp,
                        ),
                      )
                    : Icon(
                        Icons.category_rounded,
                        color: AppColor.deliveryButtonStart,
                        size: 26.sp,
                      ),
              ),
            ),
            6.hS,

            // Category Name below card
            Text(
              category.categoryName,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: textTheme.bodySmall?.copyWith(
                color: AppColor.charcoal,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
