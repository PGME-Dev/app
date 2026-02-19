import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pgme/core/theme/app_theme.dart';

enum AppDialogType { error, success, warning, info }

Future<void> showAppDialog(
  BuildContext context, {
  required String message,
  String? title,
  AppDialogType type = AppDialogType.error,
  String buttonText = 'OK',
  String? actionLabel,
  VoidCallback? onAction,
}) {
  FocusScope.of(context).unfocus();
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha:0.5),
    builder: (ctx) => _AppDialog(
      message: message,
      title: title,
      type: type,
      buttonText: buttonText,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

class _AppDialog extends StatelessWidget {
  final String message;
  final String? title;
  final AppDialogType type;
  final String buttonText;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _AppDialog({
    required this.message,
    this.title,
    required this.type,
    required this.buttonText,
    this.actionLabel,
    this.onAction,
  });

  Color get _iconColor {
    switch (type) {
      case AppDialogType.error:
        return AppColors.error;
      case AppDialogType.success:
        return AppColors.success;
      case AppDialogType.warning:
        return AppColors.warning;
      case AppDialogType.info:
        return AppColors.primaryBlue;
    }
  }

  IconData get _icon {
    switch (type) {
      case AppDialogType.error:
        return Icons.error_outline_rounded;
      case AppDialogType.success:
        return Icons.check_circle_outline_rounded;
      case AppDialogType.warning:
        return Icons.warning_amber_rounded;
      case AppDialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  String get _defaultTitle {
    switch (type) {
      case AppDialogType.error:
        return 'Error';
      case AppDialogType.success:
        return 'Success';
      case AppDialogType.warning:
        return 'Warning';
      case AppDialogType.info:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha:0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title ?? _defaultTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (actionLabel != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onAction?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.divider,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
