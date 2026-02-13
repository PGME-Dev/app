import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pgme/core/constants/api_constants.dart';
import 'package:pgme/core/services/api_service.dart';
import 'package:pgme/core/utils/responsive_helper.dart';

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
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  double _downloadProgress = 0;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      String pdfUrl;

      if (widget.pdfUrl != null) {
        pdfUrl = widget.pdfUrl!;
      } else {
        final apiService = ApiService();
        final response = await apiService.dio.get(
          ApiConstants.documentViewUrl(widget.documentId!),
        );
        pdfUrl = response.data['data']['url'] as String;
      }

      if (!mounted) return;

      // Download PDF to temp directory
      final dir = await getTemporaryDirectory();
      final fileName = 'pgme_${widget.documentId ?? pdfUrl.hashCode}.pdf';
      final filePath = '${dir.path}/$fileName';

      // Check if already cached
      final file = File(filePath);
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _localPath = filePath;
            _isLoading = false;
          });
        }
        return;
      }

      // Download with progress
      await Dio().download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
      }
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
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
        ),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: isTablet ? 64 : 48, color: Colors.grey),
                  SizedBox(height: isTablet ? 21 : 16),
                  Text(_error!, style: TextStyle(fontSize: isTablet ? 20 : 16)),
                  SizedBox(height: isTablet ? 21 : 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                        _downloadProgress = 0;
                      });
                      _loadPdf();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(value: _downloadProgress > 0 ? _downloadProgress : null),
                      if (_downloadProgress > 0) ...[
                        SizedBox(height: isTablet ? 21 : 16),
                        Text(
                          '${(_downloadProgress * 100).toInt()}%',
                          style: TextStyle(fontSize: isTablet ? 17 : 14, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                )
              : Stack(
                  children: [
                    PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: false,
                      onRender: (pages) {
                        if (mounted) setState(() => _totalPages = pages ?? 0);
                      },
                      onPageChanged: (page, total) {
                        if (mounted) setState(() => _currentPage = page ?? 0);
                      },
                      onError: (error) {
                        debugPrint('PDFView error: $error');
                        if (mounted) {
                          setState(() => _error = 'Failed to render PDF');
                        }
                      },
                    ),
                    if (_totalPages > 1)
                      Positioned(
                        bottom: isTablet ? 24 : 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 8 : 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                            ),
                            child: Text(
                              '${_currentPage + 1} / $_totalPages',
                              style: TextStyle(color: Colors.white, fontSize: isTablet ? 16 : 13),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
