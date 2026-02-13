import 'package:flutter/material.dart';

/// Responsive helper for tablet optimization.
/// Provides device type detection and responsive scaling utilities.
class ResponsiveHelper {
  /// Tablet breakpoint: devices with shortest side >= 600dp
  static const double tabletBreakpoint = 600.0;

  /// Max content width on tablets to prevent overly wide layouts
  static const double maxContentWidth = 600.0;

  /// Check if the device is a tablet based on shortest side
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= tabletBreakpoint;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns a value based on device type: phone value or tablet value
  static T value<T>(BuildContext context, {required T phone, required T tablet}) {
    return isTablet(context) ? tablet : phone;
  }

  /// Responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    if (!isTablet(context)) return 16.0;
    final width = screenWidth(context);
    // Center content with side margins on tablets
    return ((width - maxContentWidth) / 2).clamp(24.0, double.infinity);
  }

  /// Responsive font scale factor for tablets (slightly larger text)
  static double fontScale(BuildContext context) {
    return isTablet(context) ? 1.15 : 1.0;
  }

  /// Responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    return isTablet(context) ? baseSize * 1.2 : baseSize;
  }

  /// Responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    return isTablet(context) ? baseSpacing * 1.25 : baseSpacing;
  }

  /// Get constrained content width (prevents content from being too wide on tablets)
  static double contentWidth(BuildContext context) {
    final width = screenWidth(context);
    if (!isTablet(context)) return width;
    return width.clamp(0, maxContentWidth);
  }

  /// Wraps a child widget with centered max-width constraint for tablets
  static Widget constrainedContent({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    if (!isTablet(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? maxContentWidth,
        ),
        child: child,
      ),
    );
  }

  /// Get responsive grid cross-axis count based on screen width
  static int gridColumns(BuildContext context, {int phoneColumns = 1, int tabletColumns = 2}) {
    return isTablet(context) ? tabletColumns : phoneColumns;
  }

  /// Get navbar width responsive to device
  static double navBarWidth(BuildContext context) {
    final width = screenWidth(context);
    if (!isTablet(context)) {
      return width > 380 ? 361.0 : width * 0.95;
    }
    // Tablet: wider navbar but still centered, max 500px
    return width > 520 ? 500.0 : width * 0.85;
  }

  /// Get carousel height responsive to device
  static double carouselHeight(BuildContext context) {
    return isTablet(context) ? 200.0 : 140.0;
  }

  /// Get responsive card height for ForYou section
  static double forYouCardHeight(BuildContext context) {
    return isTablet(context) ? 340.0 : 281.0;
  }

  /// Faculty card dimensions
  static double facultyCardWidth(BuildContext context) {
    return isTablet(context) ? 170.0 : 140.0;
  }

  static double facultyCardHeight(BuildContext context) {
    return isTablet(context) ? 185.0 : 148.0;
  }

  /// Faculty photo size
  static double facultyPhotoSize(BuildContext context) {
    return isTablet(context) ? 100.0 : 88.0;
  }

  /// Profile avatar size on dashboard header
  static double profileAvatarSize(BuildContext context) {
    return isTablet(context) ? 52.0 : 44.0;
  }

  /// Action button size on dashboard header
  static double actionButtonSize(BuildContext context) {
    return isTablet(context) ? 44.0 : 38.0;
  }

  /// Order book card height
  static double orderBookCardHeight(BuildContext context) {
    return isTablet(context) ? 120.0 : 100.0;
  }
}
