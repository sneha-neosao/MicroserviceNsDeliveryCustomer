import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../core/theme/app_color.dart';
import '../data/models/home_response.dart';

/// Section widget for Banner type:
/// - Sliding rectangular cards with rounded corners
/// - Dots indicator at the bottom (active = orange, inactive = grey)
class HomeBannerSectionWidget extends StatefulWidget {
  final HomeSectionModel section;
  final ValueChanged<HomeBannerItemModel>? onBannerTap;

  const HomeBannerSectionWidget({
    super.key,
    required this.section,
    this.onBannerTap,
  });

  @override
  State<HomeBannerSectionWidget> createState() => _HomeBannerSectionWidgetState();
}

class _HomeBannerSectionWidgetState extends State<HomeBannerSectionWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.section.banners;
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.section.title.isNotEmpty &&
            widget.section.title.toLowerCase() != 'string') ...[
          Text(
            widget.section.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColor.charcoal,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
          ),
          10.hS,
        ],

        // Sliding rectangular cards
        SizedBox(
          height: 145.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _BannerCard(
                banner: banner,
                onTap: () => widget.onBannerTap?.call(banner),
              );
            },
          ),
        ),

        // Dots indicator at bottom (active = orange, inactive = grey)
        if (banners.length > 1) ...[
          8.hS,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.5.w),
                width: isActive ? 18.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColor.deliveryButtonStart
                      : AppColor.slateGrey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeBannerItemModel banner;
  final VoidCallback onTap;

  const _BannerCard({
    required this.banner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColor.deliveryInputBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          color: AppColor.transparent,
          child: InkWell(
            onTap: onTap,
            child: banner.image != null && banner.image!.isNotEmpty
                ? Image.network(
                    banner.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColor.deliveryInputBg,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.deliveryButtonStart,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => _FallbackBannerDesign(
                      title: banner.title ?? 'Special Offer',
                    ),
                  )
                : _FallbackBannerDesign(
                    title: banner.title ?? 'Special Offer',
                  ),
          ),
        ),
      ),
    );
  }
}

class _FallbackBannerDesign extends StatelessWidget {
  final String title;

  const _FallbackBannerDesign({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.deliveryButtonStart,
            AppColor.deliveryButtonEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColor.pureWhite.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'EXCLUSIVE DEAL',
                    style: TextStyle(
                      color: AppColor.pureWhite,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                8.hS,
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.pureWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.local_offer_rounded,
            color: AppColor.pureWhite.withValues(alpha: 0.8),
            size: 42.sp,
          ),
        ],
      ),
    );
  }
}
