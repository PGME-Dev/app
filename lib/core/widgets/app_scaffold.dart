import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';

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
                    label: 'Home',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    route: '/home',
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    label: 'Theory',
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book,
                    route: '/revision-series',
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    label: 'Practical',
                    icon: Icons.science_outlined,
                    activeIcon: Icons.science,
                    route: '/practical-series',
                    activeColor: activeIconColor,
                    inactiveColor: inactiveIconColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    label: 'Notes',
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description,
                    route: '/your-notes',
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
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = currentIndex == index;
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isOnCurrentRoute = currentLocation.startsWith(route.split('?').first);

    return GestureDetector(
      onTap: () {
        if (!isOnCurrentRoute) {
          context.go(route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: activeColor,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
