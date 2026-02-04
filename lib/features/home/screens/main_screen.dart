import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/home/screens/dashboard_screen.dart';
import 'package:pgme/features/home/screens/guest_dashboard_screen.dart';
import 'package:pgme/features/home/providers/dashboard_provider.dart';
import 'package:pgme/features/notes/screens/notes_list_screen.dart';
import 'package:pgme/features/notes/screens/your_notes_screen.dart';
import 'package:pgme/features/settings/screens/profile_screen.dart';
import 'package:pgme/features/auth/providers/auth_provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final bool isSubscribed;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.isSubscribed = false, // Default to guest/unpurchased user
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check session validity when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkSessionValidity();
    }
  }

  Future<void> _checkSessionValidity() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final isValid = await authProvider.checkSessionValidity();
      if (!isValid && mounted) {
        // Session is invalid, redirect to login
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Session check error: $e');
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;

    // Check subscription status from both widget parameter and provider
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final isSubscribed = widget.isSubscribed || (dashboardProvider.hasActivePurchase ?? false);

    final screens = [
      // Show GuestDashboardScreen for new users, DashboardScreen for subscribed users
      isSubscribed ? const DashboardScreen() : const GuestDashboardScreen(),
      // Show YourNotesScreen for both subscribed and unsubscribed users
      const YourNotesScreen(),
      // Show NotesListScreen for both - with different content based on subscription
      NotesListScreen(isSubscribed: isSubscribed),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: screens[_currentIndex],
    );
  }
}
