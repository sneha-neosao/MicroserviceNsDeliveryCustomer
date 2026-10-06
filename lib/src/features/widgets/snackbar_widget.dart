import 'package:flutter/material.dart';
import '../../core/extensions/integer_sizedbox_extension.dart';
import '../../core/theme/app_color.dart';
import '../../routes/app_route_conf.dart';

/// Shows a custom Toast/SnackBar using an OverlayEntry.
/// This guarantees it will always appear on top of dialogs, bottom sheets, etc.
void appSnackBar(BuildContext context, Color color, String label) {
  OverlayState? overlay;
  try {
    overlay = Overlay.of(context);
  } catch (_) {
    // Overlay lookup failed (e.g. if context is the root Navigator context itself)
  }

  overlay ??= globalNavigator.currentState?.overlay;

  if (overlay == null) {
    return;
  }

  late OverlayEntry entry;
  
  entry = OverlayEntry(
    builder: (context) => _AnimatedOverlaySnackBar(
      color: color,
      label: label,
      onDismissed: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _AnimatedOverlaySnackBar extends StatefulWidget {
  final Color color;
  final String label;
  final VoidCallback onDismissed;

  const _AnimatedOverlaySnackBar({
    required this.color,
    required this.label,
    required this.onDismissed,
  });

  @override
  State<_AnimatedOverlaySnackBar> createState() => _AnimatedOverlaySnackBarState();
}

class _AnimatedOverlaySnackBarState extends State<_AnimatedOverlaySnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding, taking safe area into account.
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom +
        24.0;

    return Positioned(
      bottom: bottomPadding,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: AppColor.transparent,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColor.deliveryButtonStart,
                    AppColor.deliveryButtonEnd,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.deliveryButtonStart.withValues(alpha: 0.25),
                    blurRadius: 14.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppColor.pureWhite,
                  borderRadius: BorderRadius.circular(23.5),
                ),
                child: Row(
                  children: [
                    // White circle with app short logo
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.pureWhite,
                        border: Border.all(
                          color: AppColor.border,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.deliveryButtonStart.withValues(alpha: 0.15),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset(
                        'assets/icons/app_logo_short_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    12.wS,
                    // Display message in front of icon
                    Expanded(
                      child: Text(
                        widget.label,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.charcoal,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
