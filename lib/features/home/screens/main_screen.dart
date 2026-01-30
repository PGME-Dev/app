import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core/providers/theme_provider.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/features/home/screens/dashboard_screen.dart';
import 'package:pgme/features/home/screens/guest_dashboard_screen.dart';
import 'package:pgme/features/notes/screens/notes_list_screen.dart';
import 'package:pgme/features/notes/screens/your_notes_screen.dart';
import 'package:pgme/features/settings/screens/profile_screen.dart';

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

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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

  List<Widget> get _screens => [
    // Show GuestDashboardScreen for new users, DashboardScreen for subscribed users
    widget.isSubscribed ? const DashboardScreen() : const GuestDashboardScreen(),
    // Show YourNotesScreen for both subscribed and unsubscribed users
    const YourNotesScreen(),
    // Show NotesListScreen for both - with different content based on subscription
    NotesListScreen(isSubscribed: widget.isSubscribed),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _screens[_currentIndex],
    );
  }
}
