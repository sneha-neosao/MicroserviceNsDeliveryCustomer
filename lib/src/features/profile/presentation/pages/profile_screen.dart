import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
import '../../bloc/profile_details/profile_details_bloc.dart';
import '../../bloc/wallet_summary/wallet_summary_bloc.dart';
import '../../widgets/profile_account_management_widget.dart';
import '../../widgets/profile_header_bar_widget.dart';
import '../../widgets/profile_logout_dialog.dart';
import '../../widgets/profile_quick_actions_widget.dart';
import '../../widgets/profile_settings_support_widget.dart';
import '../../widgets/profile_user_card_widget.dart';
import '../../widgets/profile_wallet_card_widget.dart';

/// Complete Profile Screen matching the reference design:
/// - Top header bar with "My Profile" and subtitle
/// - Profile card with avatar, name, email, phone, and edit button
/// - Wallet balance card with "Add Money", Skeletonizer loader, rupees & points
/// - Quick Actions 2x2 grid (My Orders, My Wishlist, Wallet History, My Coupons)
/// - Settings & Support grouped list (Terms, Privacy, Rate Us, Share, Help)
/// - Account Management grouped card: [Logout] and [Delete Account]
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileDetailsBloc>(
          create: (_) =>
              getIt<ProfileDetailsBloc>()..add(ProfileDetailsGetEvent()),
        ),
        BlocProvider<WalletSummaryBloc>(
          create: (_) =>
              getIt<WalletSummaryBloc>()..add(WalletSummaryGetEvent()),
        ),
      ],
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  String _name = 'Sneha Jadhav';
  String _mobile = '+91 98765 43210';
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final customer = await SessionManager.getCustomerData();
    final name = await SessionManager.getUserName();
    final mobile = await SessionManager.getUserMobileNumber();

    if (mounted) {
      setState(() {
        if (customer?.name.isNotEmpty == true) {
          _name = customer!.name;
        } else if (name != null && name.isNotEmpty) {
          _name = name;
        }

        if (customer?.contact.isNotEmpty == true) {
          _mobile = customer!.contact;
        } else if (mobile != null && mobile.isNotEmpty) {
          _mobile = mobile;
        }
      });
    }
  }

  void _handleLogout() {
    ProfileLogoutDialog.show(
      context,
      onConfirmLogout: () async {
        await SessionManager.clear();
        if (mounted) {
          appSnackBar(
            context,
            AppColor.deliveryGreen,
            'Logged out successfully',
          );
          context.goNamed(AppRoute.login.name);
        }
      },
    );
  }

  void _handleDeleteAccount() {
    appSnackBar(
      context,
      AppColor.bright_red,
      'Account deletion request initiated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Header Bar pinned at the top
              Container(
                width: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                child: const ProfileHeaderBarWidget(),
              ),

              // Scrollable Body Content
              Expanded(
                child: RefreshIndicator(
                  color: AppColor.deliveryButtonStart,
                  onRefresh: () async {
                    await _loadUserData();
                    if (context.mounted) {
                      context
                          .read<ProfileDetailsBloc>()
                          .add(ProfileDetailsGetEvent());
                      context
                          .read<WalletSummaryBloc>()
                          .add(WalletSummaryGetEvent());
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 130.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Profile User Info Card (with Skeletonizer & Profile Details API)
                        BlocConsumer<ProfileDetailsBloc, ProfileDetailsState>(
                          listener: (context, profileState) {
                            if (profileState is ProfileDetailsSuccessState) {
                              final data = profileState.data.data;
                              if (data != null) {
                                setState(() {
                                  if (data.name.isNotEmpty) _name = data.name;
                                  if (data.contact.isNotEmpty) _mobile = data.contact;
                                  _profileImage = data.profileImage;
                                });
                              }
                            }
                          },
                          builder: (context, profileState) {
                            final isLoading =
                                profileState is ProfileDetailsLoadingState;
                            final data = profileState is ProfileDetailsSuccessState
                                ? profileState.data.data
                                : null;
                            final currentName =
                                data?.name.isNotEmpty == true ? data!.name : _name;
                            final currentPhone =
                                data?.contact.isNotEmpty == true
                                    ? data!.contact
                                    : _mobile;
                            final currentImage =
                                data?.profileImage ?? _profileImage;

                            return Skeletonizer(
                              enabled: isLoading,
                              child: ProfileUserCardWidget(
                                name: currentName,
                                phone: currentPhone,
                                profileImage: currentImage,
                                onEditTap: () async {
                                  final result = await context.pushNamed(
                                    AppRoute.editProfile.name,
                                  );
                                  if (result == true && context.mounted) {
                                    context
                                        .read<ProfileDetailsBloc>()
                                        .add(ProfileDetailsGetEvent());
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        16.hS,

                        // 2. Wallet Balance Card (with Skeletonizer & Real API Data)
                        BlocBuilder<WalletSummaryBloc, WalletSummaryState>(
                          builder: (context, walletState) {
                            final isLoading =
                                walletState is WalletSummaryLoadingState ||
                                    walletState is WalletSummaryInitialState;
                            final summaryData =
                                walletState is WalletSummarySuccessState
                                    ? walletState.data.data
                                    : null;

                            final rupees =
                                summaryData?.walletBalanceRupees ?? 0;
                            final points =
                                summaryData?.walletBalancePoints ?? 0;

                            return ProfileWalletCardWidget(
                              isLoading: isLoading,
                              rupees: rupees,
                              points: points,
                              onAddMoneyTap: () {
                                appSnackBar(
                                  context,
                                  AppColor.deliveryButtonStart,
                                  'Add Money to wallet',
                                );
                              },
                            );
                          },
                        ),
                        18.hS,

                      // 3. Quick Actions (2x2 Grid)
                      ProfileQuickActionsWidget(
                        onOrdersTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'My Orders',
                          );
                        },
                        onWishlistTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'My Wishlist',
                          );
                        },
                        onWalletHistoryTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Wallet History',
                          );
                        },
                        onCouponsTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'My Coupons',
                          );
                        },
                      ),
                      18.hS,

                      // 4. Settings & Support Section
                      ProfileSettingsSupportWidget(
                        onTermsTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Terms & Conditions',
                          );
                        },
                        onPrivacyTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Privacy Policy',
                          );
                        },
                        onRateUsTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Rate Us on App Store',
                          );
                        },
                        onShareAppTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Share App with friends',
                          );
                        },
                        onHelpSupportTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Help & Support',
                          );
                        },
                      ),
                      18.hS,

                      // 5. Account Management Section (Logout & Delete Account)
                      ProfileAccountManagementWidget(
                        onLogoutTap: _handleLogout,
                        onDeleteAccountTap: _handleDeleteAccount,
                      ),
                      12.hS, // 12 px space after delete account
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
