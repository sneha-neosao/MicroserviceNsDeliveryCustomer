import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/home_response.dart';

/// Widget presenting top Main Categories (e.g. Mart & Food) stacked as full-width banner cards.
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

    // Take up to 2 main categories and ensure Mart comes first, Food comes second
    final itemsToShow = categories.take(2).toList();
    itemsToShow.sort((a, b) {
      final aIsFood = a.slug.toLowerCase().contains('food') ||
          a.mainCategoryName.toLowerCase().contains('food');
      final bIsFood = b.slug.toLowerCase().contains('food') ||
          b.mainCategoryName.toLowerCase().contains('food');
      if (aIsFood && !bIsFood) return 1;
      if (!aIsFood && bIsFood) return -1;
      return 0;
    });

    return Column(
      children: [
        for (int i = 0; i < itemsToShow.length; i++) ...[
          if (i > 0) 12.hS,
          _MainCategoryCard(
            category: itemsToShow[i],
            onTap: () => onCategoryTap?.call(itemsToShow[i]),
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
    final isFood = category.slug.toLowerCase().contains('food') ||
        category.mainCategoryName.toLowerCase().contains('food');

    // Theme Gradients: Orange for Food, Green for Mart
    final mainGradientColors = isFood
        ? const [
            Color(0xFFFF5500),
            Color(0xFFFF6600),
            Color(0xFFFF7A00),
          ]
        : const [
            Color(0xFF0C7A3F),
            Color(0xFF11934D),
            Color(0xFF18AC5B),
          ];

    final shadowColor =
        isFood ? const Color(0xFFFF5500) : const Color(0xFF0C7A3F);

    return Container(
      height: 96.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFood ? const Color(0xFFFFE0CC) : const Color(0xFFD6F3E6),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Material(
          color: AppColor.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Layer 1: Category Image filling the right side
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 210.w,
                  child: category.mainCategoryImage != null &&
                          category.mainCategoryImage!.isNotEmpty
                      ? Image.network(
                          category.mainCategoryImage!,
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Skeletonizer(
                              enabled: true,
                              child: Container(
                                width: 210.w,
                                height: double.infinity,
                                color: isFood
                                    ? const Color(0xFFFFD1B3)
                                    : const Color(0xFFC2EBD7),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _FallbackImage(isFood: isFood),
                        )
                      : _FallbackImage(isFood: isFood),
                ),

                // Layer 2: Soft Lighter Curved Transition Ring (matches exact curved glow in screenshot)
                Positioned.fill(
                  child: ClipPath(
                    clipper: _BannerGlowCurveClipper(),
                    child: Container(
                      color: isFood
                          ? const Color(0xFFFF9E59).withValues(alpha: 0.85)
                          : const Color(0xFF38C172).withValues(alpha: 0.85),
                    ),
                  ),
                ),

                // Layer 3: Solid Main Curved Background (Orange / Green)
                Positioned.fill(
                  child: ClipPath(
                    clipper: _BannerCurveClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: mainGradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 4: Left Side Content (Title & "Shop Now ->" Button)
                Positioned(
                  left: 18.w,
                  top: 0,
                  bottom: 0,
                  width: 170.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.mainCategoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColor.pureWhite,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      10.hS,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.pureWhite,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColor.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            4.wS,
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14.sp,
                              color: AppColor.black,
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// Custom Clipper creating the smooth inward arch curve (concave)
class _BannerCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.58, 0);
    path.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.5,
      size.width * 0.58,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom Clipper creating the soft glow outer inward curve transition
class _BannerGlowCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.64, 0);
    path.quadraticBezierTo(
      size.width * 0.44,
      size.height * 0.5,
      size.width * 0.64,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FallbackImage extends StatelessWidget {
  final bool isFood;

  const _FallbackImage({required this.isFood});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isFood ? const Color(0xFFFFD1B3) : const Color(0xFFC2EBD7),
      child: Center(
        child: Icon(
          isFood ? Icons.fastfood_rounded : Icons.shopping_basket_rounded,
          color: isFood ? const Color(0xFFFF5500) : const Color(0xFF0C7A3F),
          size: 44.sp,
        ),
      ),
    );
  }
}


