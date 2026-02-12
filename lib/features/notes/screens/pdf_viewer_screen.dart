import 'package:flutter/material.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfViewerScreen extends StatefulWidget {
  /// Document ID — used to fetch the URL from the backend (with access control).
  final String? documentId;

  /// Direct PDF URL — used for preview URLs that don't need auth.
  /// If provided, skips the backend API call.
  final String? pdfUrl;

  final String title;

  const PdfViewerScreen({
    super.key,
    this.documentId,
    this.pdfUrl,
    this.title = 'PDF Viewer',
  }) : assert(documentId != null || pdfUrl != null);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      String pdfUrl;

      if (widget.pdfUrl != null) {
        // Direct URL provided (e.g. preview_url) — no backend call needed
        pdfUrl = widget.pdfUrl!;
      } else {
        // Fetch URL from backend with access control
        final apiService = ApiService();
        final response = await apiService.dio.get(
          ApiConstants.documentViewUrl(widget.documentId!),
        );
        pdfUrl = response.data['data']['url'] as String;
      }

      if (!mounted) return;

      // Load via Google Docs Viewer in WebView
      final viewerUrl = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(pdfUrl)}';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              debugPrint('PDF WebView error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(viewerUrl));

      setState(() {});
    } catch (e) {
      debugPrint('PDF load error: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load PDF';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      _loadPdf();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
