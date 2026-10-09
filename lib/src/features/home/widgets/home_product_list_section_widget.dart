import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/home_response.dart';
import 'home_product_card_widget.dart';

/// Section widget for Product List type:
/// - Section title above
/// - Horizontal list of Blinkit-like product cards
class HomeProductListSectionWidget extends StatelessWidget {
  final HomeSectionModel section;
  final ValueChanged<HomeProductItemModel>? onProductTap;
  final ValueChanged<HomeProductItemModel>? onAddTap;

  const HomeProductListSectionWidget({
    super.key,
    required this.section,
    this.onProductTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final products = section.products;
    if (products.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Description Header
        if (section.title.isNotEmpty && section.title.toLowerCase() != 'string') ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColor.charcoal,
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (section.description != null &&
                          section.description!.isNotEmpty) ...[
                        2.hS,
                        Text(
                          section.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColor.slateGrey,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See All',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColor.deliveryButtonStart,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.hS,
        ],

        // Horizontal scrolling list of Blinkit-like product cards
        SizedBox(
          height: 228.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, _) => 12.wS,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => onProductTap?.call(product),
                child: HomeProductCardWidget(
                  product: product,
                  onAddTap: () => onAddTap?.call(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
