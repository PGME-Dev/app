import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/constants/api_constants.dart';

class WebStoreLauncher {
  static final ApiService _apiService = ApiService();

  /// Returns true if the current platform should use the web store for digital purchases
  static bool get shouldUseWebStore => Platform.isIOS;

  /// Generate a web-login token and open Safari to the product page
  static Future<void> openProductPage(
    BuildContext context, {
    required String productType,
    required String productId,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    bool dialogShowing = true;

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          dialogShowing = false;
        },
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );

    void dismissDialog() {
      if (dialogShowing) {
        dialogShowing = false;
        try {
          navigator.pop();
        } catch (_) {}
      }
    }

    try {
      final redirectPath = '/$productType/$productId';

      final response = await _apiService.dio.post(
        ApiConstants.webLoginToken,
        data: {'redirect_path': redirectPath},
      );

      // Always dismiss loading before opening Safari
      dismissDialog();

      final token = response.data['data']['token'] as String;
      final url = Uri.parse(
        '${ApiConstants.webStoreBaseUrl}$redirectPath?token=$token',
      );

      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);

      if (!launched) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Could not open the store. Please visit store.pgme.in in your browser.'),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading if still showing
      dismissDialog();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again or visit store.pgme.in'),
        ),
      );
    }
  }
}
