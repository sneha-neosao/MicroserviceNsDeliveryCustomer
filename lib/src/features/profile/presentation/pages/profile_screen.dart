import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/integer_sizedbox_extension.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../routes/app_route_path.dart';
import '../../../widgets/snackbar_widget.dart';
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
/// - Wallet balance card with "Add Money" and illustrated wallet
/// - Quick Actions 2x2 grid (My Orders, My Wishlist, Wallet History, My Coupons)
/// - Settings & Support grouped list (Terms, Privacy, Rate Us, Share, Help)
/// - Account Management grouped card: [Logout] and [Delete Account]
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Sneha Jadhav';
  String _mobile = '+91 98765 43210';
  String _email = 'sneha.jadhav@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final customer = await SessionManager.getCustomerData();
    final name = await SessionManager.getUserName();
    final mobile = await SessionManager.getUserMobileNumber();
    final email = await SessionManager.getUserEmail();

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

        if (customer?.email.isNotEmpty == true) {
          _email = customer!.email;
        } else if (email != null && email.isNotEmpty) {
          _email = email;
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
        backgroundColor: AppColor.profileBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Header Bar pinned at the top
              Container(
                width: double.infinity,
                color: AppColor.profileBackground,
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                child: const ProfileHeaderBarWidget(),
              ),

              // Scrollable Body Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 130.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Profile User Info Card
                      ProfileUserCardWidget(
                        name: _name,
                        email: _email,
                        phone: _mobile,
                        onEditTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Edit profile opened',
                          );
                        },
                      ),
                      16.hS,

                      // 2. Wallet Balance Card
                      ProfileWalletCardWidget(
                        balance: '₹ 2,450',
                        onAddMoneyTap: () {
                          appSnackBar(
                            context,
                            AppColor.deliveryButtonStart,
                            'Add Money to wallet',
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
            ],
          ),
        ),
      ),
    );
  }
}
