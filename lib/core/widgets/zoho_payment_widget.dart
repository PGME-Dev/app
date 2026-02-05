import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';

class ZohoPaymentWidget extends StatefulWidget {
  final ZohoPaymentSession paymentSession;
  final Function(ZohoPaymentResponse) onPaymentComplete;
  final VoidCallback? onCancel;

  const ZohoPaymentWidget({
    super.key,
    required this.paymentSession,
    required this.onPaymentComplete,
    this.onCancel,
  });

  @override
  State<ZohoPaymentWidget> createState() => _ZohoPaymentWidgetState();
}

class _ZohoPaymentWidgetState extends State<ZohoPaymentWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    debugPrint('');
    debugPrint('=== ZohoPaymentWidget INIT ===');
    debugPrint('Session ID: "${widget.paymentSession.paymentSessionId}"');
    debugPrint('Amount: ${widget.paymentSession.amount} ${widget.paymentSession.currency}');
    debugPrint('=============================');
    debugPrint('');

    _initializeWebView();
  }

  void _initializeWebView() {
    // Build the backend checkout URL with payment session details
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    final checkoutUrl = '$baseUrl/checkout'
        '?session_id=${widget.paymentSession.paymentSessionId}'
        '&amount=${widget.paymentSession.amount}'
        '&currency=${widget.paymentSession.currency}';

    debugPrint('WebView: Loading checkout from $checkoutUrl');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('JS [${message.level.name}]: ${message.message}');
      })
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('JS->Flutter: ${message.message}');
          _handlePaymentResponse(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('WebView started: $url');
          },
          onPageFinished: (url) {
            debugPrint('WebView finished: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView ERROR: ${error.errorCode} - ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView nav: ${request.url}');
            final uri = Uri.parse(request.url);
            // Allow only http/https in WebView - launch everything else externally
            // This handles all UPI apps: upi://, paytmmp://, phonepe://, gpay://,
            // tez://, bhim://, cred://, intent://, etc.
            if (uri.scheme != 'http' && uri.scheme != 'https' && uri.scheme != 'about') {
              debugPrint('Launching external app: ${request.url}');
              launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      // Load from backend - gives proper HTTPS origin for Zoho SDK
      ..loadRequest(Uri.parse(checkoutUrl));
  }

  void _handlePaymentResponse(String message) {
    try {
      debugPrint('Parsing payment response: $message');
      final Map<String, dynamic> data = json.decode(message);

      final response = ZohoPaymentResponse(
        status: data['status'] as String,
        paymentId: data['payment_id'] as String?,
        paymentSessionId: data['payment_session_id'] as String?,
        signature: data['signature'] as String?,
        errorMessage: data['error_message'] as String?,
      );

      debugPrint('Payment result: status=${response.status}, paymentId=${response.paymentId}');
      widget.onPaymentComplete(response);
    } catch (e) {
      debugPrint('Error parsing payment response: $e');
      widget.onPaymentComplete(
        ZohoPaymentResponse(
          status: 'failed',
          errorMessage: 'Failed to process payment response',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment gateway...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
