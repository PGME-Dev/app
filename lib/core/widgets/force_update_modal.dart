import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/theme/app_theme.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

class ForceUpdateModal extends StatelessWidget {
  final String? storeUrl;
  final String currentVersion;
  final String? minVersion;

  const ForceUpdateModal({
    super.key,
    this.storeUrl,
    required this.currentVersion,
    this.minVersion,
  });

  Future<void> _openStore() async {
    if (storeUrl != null && storeUrl!.isNotEmpty) {
      final uri = Uri.parse(storeUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _quitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      // iOS doesn't allow programmatic exit, but we minimize the app
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveHelper.isTablet(context);

    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            width: isTablet ? 480 : 320,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Update Icon
                Container(
                  width: isTablet ? 80 : 64,
                  height: isTablet ? 80 : 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0000D1),
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: isTablet ? 44 : 36,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),

                // Title
                Text(
                  'Update Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isTablet ? 26 : 22,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 10),

                // Message
                Text(
                  'A new version of PGME is available. Please update to the latest version to continue using the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),

                // Version info
                Text(
                  'Current: v$currentVersion${minVersion != null ? '  •  Required: v$minVersion' : ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isTablet ? 13 : 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),

                // Update Now Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                    ),
                    child: TextButton(
                      onPressed: _openStore,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isTablet ? 28 : 24),
                        ),
                      ),
                      child: Text(
                        'Update Now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 10),

                // Quit Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: OutlinedButton(
                    onPressed: _quitApp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      side: BorderSide(
                        color:
                            isDark ? AppColors.darkDivider : AppColors.divider,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isTablet ? 28 : 24),
                      ),
                    ),
                    child: Text(
                      'Close App',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
