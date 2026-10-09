import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/home/home_bloc.dart';
import '../../data/models/home_response.dart';
import '../../widgets/home_banner_section_widget.dart';
import '../../widgets/home_category_list_section_widget.dart';
import '../../widgets/home_header_widget.dart';
import '../../widgets/home_main_categories_widget.dart';
import '../../widgets/home_product_list_section_widget.dart';
import '../../widgets/home_shimmer_widget.dart';
import '../../widgets/select_address_bottom_sheet.dart';
import '../../../addresses/data/models/address_list_response.dart';

/// Home Screen displaying:
/// - Top address bar with delivery location selector
/// - 2 cards in a row presenting main categories (Mart & Food)
/// - Sections sorted according to priority (1st, 2nd, etc.)
/// - Dynamic section type rendering:
///   1. Banners (sliding rectangular cards with orange/grey dots)
///   2. Category list (small square cards with title above & name below)
///   3. Product list (Blinkit-like cards with image, price, discount, heart icon, ADD button)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>(),
        ),
      ],
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  DeliveryLocationModel? _currentLocation;
  bool _hasOpenedInitialSheet = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocationAndFetch();

    // Automatically open the address selection bottom sheet upon landing on Home Screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasOpenedInitialSheet && mounted) {
        _hasOpenedInitialSheet = true;
        _openAddressBottomSheet();
      }
    });
  }

  Future<void> _loadSavedLocationAndFetch() async {
    final address = await SessionManager.getDeliveryAddress();
    final title = await SessionManager.getDeliveryAddressTitle();
    final coords = await SessionManager.getDeliveryCoordinates();

    final lat = coords?['lat'];
    final lng = coords?['lng'];

    if (mounted) {
      if (address != null) {
        setState(() {
          _currentLocation = DeliveryLocationModel(
            formattedAddress: address,
            title: title ?? 'Home Delivery',
            locality: '',
            city: '',
            postalCode: '',
            latitude: lat ?? 0.0,
            longitude: lng ?? 0.0,
          );
        });
      }

      // Fetch Home API with coordinates
      context.read<HomeBloc>().add(
            HomeGetEvent(
              offset: 1,
              limit: 10,
              lat: lat ?? 16.69188459279902,
              lng: lng ?? 74.23528667539358,
            ),
          );
    }
  }

  Future<void> _openAddressScreen() async {
    final result = await context.pushNamed<dynamic>(AppRoute.address.name);
    if (mounted) {
      if (result is AddressModel) {
        final title = result.label.isNotEmpty && result.label.toLowerCase() != 'string'
            ? result.label[0].toUpperCase() + result.label.substring(1)
            : result.deliveryName.isNotEmpty
                ? result.deliveryName
                : 'Delivery Address';
        final fullAddress = result.fullAddress.isNotEmpty ? result.fullAddress : result.addressLine;
        setState(() {
          _currentLocation = DeliveryLocationModel(
            formattedAddress: fullAddress,
            title: title,
            locality: result.city,
            city: result.city,
            postalCode: result.pincode,
            latitude: result.lat,
            longitude: result.lng,
          );
        });
        context.read<HomeBloc>().add(
              HomeGetEvent(
                offset: 1,
                limit: 10,
                lat: result.lat != 0.0 ? result.lat : 16.69188459279902,
                lng: result.lng != 0.0 ? result.lng : 74.23528667539358,
              ),
            );
        return;
      } else if (result is DeliveryLocationModel) {
        setState(() {
          _currentLocation = result;
        });
        context.read<HomeBloc>().add(
              HomeGetEvent(
                offset: 1,
                limit: 10,
                lat: result.latitude != 0.0 ? result.latitude : 16.69188459279902,
                lng: result.longitude != 0.0 ? result.longitude : 74.23528667539358,
              ),
            );
        return;
      }
      _loadSavedLocationAndFetch();
    }
  }

  void _openAddressBottomSheet() {
    SelectAddressBottomSheet.show(
      context,
      onLocationSelected: (selectedLocation) {
        setState(() {
          _currentLocation = selectedLocation;
        });
        context.read<HomeBloc>().add(
              HomeGetEvent(
                offset: 1,
                limit: 10,
                lat: selectedLocation.latitude != 0.0
                    ? selectedLocation.latitude
                    : 16.69188459279902,
                lng: selectedLocation.longitude != 0.0
                    ? selectedLocation.longitude
                    : 74.23528667539358,
              ),
            );
      },
    );
  }

  Widget _buildSection(HomeSectionModel section) {
    final type = section.sectionType.toLowerCase();

    // 1. Banner Section: sliding rectangular cards with dots
    if (type.contains('banner') || section.banners.isNotEmpty) {
      return HomeBannerSectionWidget(
        section: section,
        onBannerTap: (banner) {},
      );
    }

    // 2. Category List: small square cards with name below & title above
    if (type.contains('category') || section.categories.isNotEmpty) {
      return HomeCategoryListSectionWidget(
        section: section,
        onCategoryTap: (category) {},
      );
    }

    // 3. Product List: Blinkit-like cards with image, price, discount, heart icon, ADD button
    if (type.contains('product') || section.products.isNotEmpty) {
      return HomeProductListSectionWidget(
        section: section,
        onProductTap: (product) {},
        onAddTap: (product) {
          appSnackBar(
            context,
            AppColor.deliveryGreen,
            '${product.productName.isNotEmpty ? product.productName : "Item"} added to cart',
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Top Header: Only Address Bar
          HomeHeaderWidget(
            location: _currentLocation,
            onAddressTap: _openAddressScreen,
          ),

          // 2. Scrollable Body Content
          Expanded(
            child: RefreshIndicator(
              color: AppColor.deliveryButtonStart,
              onRefresh: () async {
                await _loadSavedLocationAndFetch();
              },
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeFailureState) {
                    appSnackBar(
                      context,
                      AppColor.bright_red,
                      state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is HomeLoadingState || state is HomeInitialState) {
                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: const [
                        HomeShimmerWidget(),
                      ],
                    );
                  }

                  if (state is HomeFailureState) {
                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 60.h,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColor.bright_red,
                                size: 48.sp,
                              ),
                              12.hS,
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColor.slateGrey,
                                    ),
                              ),
                              16.hS,
                              ElevatedButton(
                                onPressed: _loadSavedLocationAndFetch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.deliveryButtonStart,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColor.pureWhite,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final homeData = (state as HomeSuccessState).data.data;
                  final mainCategories =
                      homeData?.mainCategories?.items ?? <MainCategoryModel>[];
                  final sections =
                      homeData?.homeSections?.items ?? <HomeSectionModel>[];

                  // Sort sections by priority (1st priority first, 2nd next, etc.)
                  final sortedSections = List<HomeSectionModel>.from(sections)
                    ..sort((a, b) => a.priority.compareTo(b.priority));

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 110.h),
                    children: [
                      // 2 Main Category Cards in a Row (e.g. Mart & Food)
                      if (mainCategories.isNotEmpty) ...[
                        HomeMainCategoriesWidget(
                          categories: mainCategories,
                          onCategoryTap: (cat) {},
                        ),
                        18.hS,
                      ],

                      // Sections according to Priority
                      for (int i = 0; i < sortedSections.length; i++) ...[
                        _buildSection(sortedSections[i]),
                        if (i < sortedSections.length - 1) 18.hS,
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
