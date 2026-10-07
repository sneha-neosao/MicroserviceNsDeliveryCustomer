import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_color.dart';

/// Search bar widget on top of the map with auto-complete search results.
class MapSearchBarWidget extends StatefulWidget {
  final ValueChanged<DeliveryLocationModel> onLocationSelected;
  final VoidCallback onBack;

  const MapSearchBarWidget({
    super.key,
    required this.onLocationSelected,
    required this.onBack,
  });

  @override
  State<MapSearchBarWidget> createState() => _MapSearchBarWidgetState();
}

class _MapSearchBarWidgetState extends State<MapSearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  List<DeliveryLocationModel> _suggestions = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) async {
    if (query.trim().length < 3) {
      if (_suggestions.isNotEmpty) {
        setState(() {
          _suggestions = [];
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await LocationService.searchAddress(query);

    if (mounted) {
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _suggestions = [];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: AppColor.pureWhite,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back Button
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColor.charcoal,
                  size: 18,
                ),
              ),
              // Search Input Field
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColor.charcoal,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search area, street, or landmark...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColor.deliveryInputHint,
                      fontSize: 13.5.sp,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              // Indicator or Clear
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.deliveryButtonStart,
                    ),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColor.slateGrey,
                    size: 18,
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColor.deliveryButtonStart,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
        // Search Results Dropdown List
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 220.h),
            decoration: BoxDecoration(
              color: AppColor.pureWhite,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => Divider(
                color: AppColor.border.withValues(alpha: 0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColor.deliveryButtonStart,
                    size: 20,
                  ),
                  title: Text(
                    item.title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColor.charcoal,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  subtitle: Text(
                    item.formattedAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColor.slateGrey,
                      fontSize: 11.5.sp,
                    ),
                  ),
                  onTap: () {
                    _clearSearch();
                    primaryFocus?.unfocus();
                    widget.onLocationSelected(item);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
