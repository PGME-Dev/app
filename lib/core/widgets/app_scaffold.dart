import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool isSubscribed;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.isSubscribed = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Get subscription status from DashboardProvider
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final hasTheorySubscription = dashboardProvider.hasTheorySubscription;
    final hasPracticalSubscription = dashboardProvider.hasPracticalSubscription;
    final hasAnySubscription = hasTheorySubscription || hasPracticalSubscription;

    // Determine video icon route based on subscription
    String videoRoute;
    if (hasTheorySubscription) {
      videoRoute = '/revision-series?subscribed=true';
    } else if (hasPracticalSubscription) {
      videoRoute = '/practical-series?subscribed=true';
    } else {
      videoRoute = '/home?tab=2';
    }

    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final navBarColor = isDark ? AppColors.darkSurface : const Color(0xFFF6F6F6);
    final inactiveIconColor = isDark ? AppColors.darkTextTertiary : const Color(0xFF666666);
    final activeIconColor = isDark ? const Color(0xFF00BEFA) : const Color(0xFF00C2FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          child,
          // Persistent Bottom Navigation Bar
          Positioned(
            bottom: 20,
            left: (MediaQuery.of(context).size.width - 361) / 2,
            child: Container(
              width: 361,
              height: 65,
              decoration: BoxDecoration(
                color: navBarColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x4D000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 12,
                          spreadRadius: 6,
                          offset: Offset(0, 8),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    route: '/home${hasAnySubscription ? '?subscribed=true' : ''}',
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description,
                    route: '/home?tab=1${hasAnySubscription ? '&subscribed=true' : ''}',
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    icon: Icons.videocam_outlined,
                    activeIcon: Icons.videocam,
                    route: videoRoute,
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    route: '/home?tab=3${hasAnySubscription ? '&subscribed=true' : ''}',
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = currentIndex == index;
    // Get current location to check if we're on a non-home route like /settings
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isOnNonHomeRoute = !currentLocation.startsWith('/home');

    return GestureDetector(
      onTap: () {
        // Always navigate if we're on a non-home route (like /settings)
        // or if this nav item is not currently active
        if (isOnNonHomeRoute || !isActive) {
          context.go(route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? activeColor : inactiveColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
