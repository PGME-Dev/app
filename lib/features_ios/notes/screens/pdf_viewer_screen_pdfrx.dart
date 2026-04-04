import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:pgme/core_ios/constants/api_constants.dart';
import 'package:pgme/core_ios/models/annotation_bounds.dart';
import 'package:pgme/core_ios/providers/theme_provider.dart';
import 'package:pgme/core_ios/services/api_service.dart';
import 'package:pgme/core_ios/services/bookmark_service.dart';
import 'package:pgme/core_ios/services/highlight_service.dart';
import 'package:pgme/core_ios/services/download_service.dart';
import 'package:pgme/core_ios/services/progress_service.dart';
import 'package:pgme/core_ios/theme/app_theme.dart';
import 'package:pgme/core_ios/utils/responsive_helper.dart';
import 'package:pgme/core_ios/widgets/app_dialog.dart';
import 'package:pgme/features_ios/notes/widgets/bookmarks_drawer.dart';

// ─────────────────────────────────────────────────────────────────────
// Local data class to replace Syncfusion's Annotation objects.
// Holds everything needed to paint a highlight/underline on the canvas.
// ─────────────────────────────────────────────────────────────────────
class _AnnotationData {
  final List<AnnotationTextBounds> bounds;
  final Color color;
  const _AnnotationData({required this.bounds, required this.color});
}

class PdfViewerScreen extends StatefulWidget {
  final String? documentId;
  final String? pdfUrl;
  final String? filePath;
  final String title;

  const PdfViewerScreen({
    super.key,
    this.documentId,
    this.pdfUrl,
    this.filePath,
    this.title = 'PDF Viewer',
  }) : assert(documentId != null || pdfUrl != null || filePath != null);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HighlightService _highlightService = HighlightService();
  final BookmarkService _bookmarkService = BookmarkService();
  final ProgressService _progressService = ProgressService();

  String? _localPath;
  bool _isLoading = true;
  bool _isPdfReady = false;
  String? _error;
  double _downloadProgress = 0;
  bool _isSearchOpen = false;

  // Search
  PdfTextSearcher? _textSearcher;
  final TextEditingController _searchController = TextEditingController();

  // Annotations — keyed by backend highlight_id
  final Map<String, _AnnotationData> _highlights = {};
  final Map<String, _AnnotationData> _underlines = {};
  final Map<String, String?> _annotationNotes = {};
  final Map<String, String> _annotationTexts = {};
  final Map<String, List<AnnotationTextBounds>> _annotationBounds = {};

  // Context menu overlay
  OverlayEntry? _contextMenuOverlay;
  Timer? _contextMenuDebounce;

  // Current text selection (captured from pdfrx callback)
  List<PdfTextRanges>? _currentSelections;
  String? _currentSelectedText;

  // Captured at context menu show time — survives selection clearing when
  // the user taps an overlay button outside the SelectionArea.
  List<AnnotationTextBounds>? _capturedBounds;
  String? _capturedText;

  // Bookmarks
  final Map<int, String> _bookmarkedPages = {};
  final Map<String, String?> _bookmarkNotes = {};

  // Progress
  final ValueNotifier<int> _currentPage = ValueNotifier(1);
  Timer? _progressDebounceTimer;

  // Dark mode
  bool _isPdfDarkMode = false;

  // Guards
  bool _highlightsLoaded = false;
  bool _bookmarksLoaded = false;

  // Cached viewer widget — must not be recreated on setState
  Widget? _cachedPdfViewer;

  /// Call instead of plain setState when annotation data changes.
  /// Uses controller.invalidate() to repaint annotations without
  /// recreating the PdfViewer widget (which would reset the document).
  void _setAnnotationState(VoidCallback fn) {
    fn();
    if (_pdfController.isReady) {
      _pdfController.invalidate();
    }
  }

  static const Map<String, Color> highlightColors = {
    'yellow': Color(0x80FFEB3B),
    'green': Color(0x8066BB6A),
    'blue': Color(0x8042A5F5),
    'pink': Color(0x80EC407A),
  };

  static const Color underlineColor = Color(0xFF1565C0);

  static const ColorFilter _invertColorFilter = ColorFilter.matrix(<double>[
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isDark =
            Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
        setState(() => _isPdfDarkMode = isDark);
      }
    });
    _loadPdf();
  }

  @override
  void dispose() {
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
    _contextMenuDebounce?.cancel();
    _progressDebounceTimer?.cancel();
    final documentId = widget.documentId;
    final lastPage = _currentPage.value;
    if (documentId != null && lastPage > 0) {
      _progressService.updateDocumentProgress(
        documentId: documentId,
        pageNumber: lastPage,
      );
    }
    _currentPage.dispose();
    _textSearcher?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── PDF loading (identical to Syncfusion version) ─────────────────

  Future<void> _loadPdf() async {
    try {
      if (widget.filePath != null) {
        if (mounted) {
          setState(() {
            _localPath = widget.filePath;
            _isLoading = false;
          });
        }
        return;
      }

      if (widget.documentId != null) {
        final docFileName = 'doc_${widget.documentId}.pdf';
        final ebookFileName = 'ebook_${widget.documentId}.pdf';
        final downloadedPath =
            await DownloadService().getDownloadedPath(docFileName) ??
                await DownloadService().getDownloadedPath(ebookFileName);
        if (downloadedPath != null) {
          final file = File(downloadedPath);
          final fileSize = await file.length();
          if (fileSize > 0 && mounted) {
            setState(() {
              _localPath = downloadedPath;
              _isLoading = false;
            });
            return;
          }
        }
      }

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

      final dir = await getTemporaryDirectory();
      final fileName = 'pgme_${widget.documentId ?? pdfUrl.hashCode}.pdf';
      final filePath = '${dir.path}/$fileName';

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

      await Dio().download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
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

  // ── Progress ──────────────────────────────────────────────────────

  Future<void> _restoreProgress() async {
    if (widget.documentId == null) return;
    try {
      final progress =
          await _progressService.getDocumentProgress(widget.documentId!);
      final savedPage = progress['page_number'] as int? ?? 1;
      if (savedPage > 1 && mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _pdfController.goToPage(pageNumber: savedPage);
        }
      }
    } catch (e) {
      debugPrint('Failed to restore progress: $e');
    }
  }

  void _debouncedSaveProgress(int pageNumber) {
    _progressDebounceTimer?.cancel();
    _progressDebounceTimer = Timer(const Duration(seconds: 2), () {
      _saveProgress(pageNumber);
    });
  }

  Future<void> _saveProgress(int pageNumber) async {
    if (widget.documentId == null) return;
    try {
      await _progressService.updateDocumentProgress(
        documentId: widget.documentId!,
        pageNumber: pageNumber,
      );
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }

  // ── Bookmarks ─────────────────────────────────────────────────────

  Future<void> _loadBookmarks() async {
    if (widget.documentId == null || _bookmarksLoaded) return;
    _bookmarksLoaded = true;
    try {
      final bookmarks =
          await _bookmarkService.getBookmarks(widget.documentId!);
      if (mounted) {
        setState(() {
          _bookmarkedPages.clear();
          _bookmarkNotes.clear();
          for (final b in bookmarks) {
            final pageNumber = b['page_number'] as int;
            final bookmarkId = b['bookmark_id'] as String;
            _bookmarkedPages[pageNumber] = bookmarkId;
            _bookmarkNotes[bookmarkId] = b['note'] as String?;
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to load bookmarks: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    if (widget.documentId == null) return;
    final page = _currentPage.value;

    if (_bookmarkedPages.containsKey(page)) {
      final bookmarkId = _bookmarkedPages[page]!;
      final savedNote = _bookmarkNotes[bookmarkId];
      setState(() {
        _bookmarkedPages.remove(page);
        _bookmarkNotes.remove(bookmarkId);
      });
      try {
        await _bookmarkService.deleteBookmark(bookmarkId);
      } catch (e) {
        if (mounted) {
          setState(() {
            _bookmarkedPages[page] = bookmarkId;
            _bookmarkNotes[bookmarkId] = savedNote;
          });
          showAppDialog(context,
              message: 'Failed to remove bookmark', type: AppDialogType.info);
        }
      }
    } else {
      try {
        final result = await _bookmarkService.addBookmark(
          documentId: widget.documentId!,
          pageNumber: page,
        );
        if (mounted) {
          setState(() {
            final bookmarkId = result['bookmark_id'] as String;
            _bookmarkedPages[page] = bookmarkId;
            _bookmarkNotes[bookmarkId] = result['note'] as String?;
          });
        }
      } catch (e) {
        if (mounted) {
          showAppDialog(context,
              message: 'Failed to add bookmark', type: AppDialogType.info);
        }
      }
    }
  }

  // ── Load highlights/underlines from backend ───────────────────────

  Future<void> _loadHighlights() async {
    if (widget.documentId == null || _highlightsLoaded) return;
    _highlightsLoaded = true;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      final highlights =
          await _highlightService.getHighlights(widget.documentId!);

      for (final h in highlights) {
        try {
          final colorName = h['color'] ?? 'yellow';
          final color =
              highlightColors[colorName] ?? highlightColors['yellow']!;
          final highlightId = h['highlight_id'] as String;
          final boundsData = h['bounds_data'] as List?;
          final annotationType =
              (h['annotation_type'] as String?) ?? 'highlight';
          final note = h['note'] as String?;

          if (boundsData == null || boundsData.isEmpty) continue;

          final bounds = boundsData
              .map<AnnotationTextBounds>(
                  (b) => AnnotationTextBounds.fromJson(b as Map<String, dynamic>))
              .toList();

          final data = _AnnotationData(
            bounds: bounds,
            color: annotationType == 'underline' ? underlineColor : color,
          );

          if (annotationType == 'underline') {
            _underlines[highlightId] = data;
          } else {
            _highlights[highlightId] = data;
          }

          _annotationNotes[highlightId] = note;
          _annotationTexts[highlightId] =
              (h['highlighted_text'] as String?) ?? '';
          _annotationBounds[highlightId] = bounds;
        } catch (e) {
          debugPrint('Failed to restore highlight: $e');
        }
      }

      if (mounted) _setAnnotationState(() {});
    } catch (e) {
      debugPrint('Failed to load highlights: $e');
    }
  }

  // ── Coordinate conversion ─────────────────────────────────────────

  Rect _boundsToScreenRect(
      AnnotationTextBounds bounds, PdfPage page, Rect pageRect) {
    // Convert stored bounds (PDF coordinates) to screen rect using pdfrx's
    // built-in coordinate conversion which handles Y-flip and rotation.
    final pdfRect = PdfRect(
      bounds.left,
      bounds.top,
      bounds.left + bounds.width,
      bounds.top - bounds.height, // PDF coords: bottom = top - height
    );
    return pdfRect.toRectInPageRect(page: page, pageRect: pageRect);
  }

  // ── Canvas painting for annotations ───────────────────────────────

  void _paintAnnotations(Canvas canvas, Rect pageRect, PdfPage page) {
    final pageNumber = page.pageNumber;

    // Paint highlights
    for (final entry in _highlights.entries) {
      for (final bounds in entry.value.bounds) {
        if (bounds.pageNumber != pageNumber) continue;
        final rect = _boundsToScreenRect(bounds, page, pageRect);
        canvas.drawRect(
          rect,
          Paint()
            ..color = entry.value.color
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Paint underlines
    for (final entry in _underlines.entries) {
      for (final bounds in entry.value.bounds) {
        if (bounds.pageNumber != pageNumber) continue;
        final rect = _boundsToScreenRect(bounds, page, pageRect);
        canvas.drawLine(
          Offset(rect.left, rect.bottom),
          Offset(rect.right, rect.bottom),
          Paint()
            ..color = underlineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }
  }

  // ── Page overlays for annotation tap targets ──────────────────────

  List<Widget> _buildPageOverlays(
      BuildContext context, Rect pageRect, PdfPage page) {
    final pageNumber = page.pageNumber;
    final widgets = <Widget>[];

    void addTapTargets(
        Map<String, _AnnotationData> map, bool isUnderline) {
      for (final entry in map.entries) {
        for (final bounds in entry.value.bounds) {
          if (bounds.pageNumber != pageNumber) continue;
          final rect = _boundsToScreenRect(bounds, page, pageRect);
          widgets.add(
            Positioned(
              left: rect.left - pageRect.left,
              top: rect.top - pageRect.top,
              width: rect.width,
              height: rect.height,
              child: GestureDetector(
                onTap: () => _showAnnotationMenu(entry.key, isUnderline),
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
          );
        }
      }
    }

    addTapTargets(_highlights, false);
    addTapTargets(_underlines, true);
    return widgets;
  }

  // ── Text selection handling ────────────────────────────────────────

  void _handleTextSelectionChange(List<PdfTextRanges> selections) {
    final hasSelection = selections.isNotEmpty &&
        selections.any((s) => s.isNotEmpty);
    if (hasSelection) {
      _contextMenuDebounce?.cancel();
      _removeContextMenu();

      _currentSelections = selections;
      _currentSelectedText =
          selections.map((s) => s.text).join(' ');

      _contextMenuDebounce = Timer(const Duration(milliseconds: 300), () {
        if (!mounted || _currentSelections == null) return;
        _showContextMenuFromSelection();
      });
    } else {
      _currentSelections = null;
      _currentSelectedText = null;
      _removeContextMenu();
    }
  }

  void _showContextMenuFromSelection() {
    if (_currentSelections == null || _currentSelections!.isEmpty) {
      return;
    }
    // Capture bounds NOW — by the time the user taps a button in the overlay,
    // the SelectionArea may have already cleared _currentSelections.
    _capturedBounds = _selectionToBounds(_currentSelections!);
    _capturedText = _currentSelectedText;

    final screenSize = MediaQuery.of(context).size;
    _showContextMenu(Offset(screenSize.width / 2, 120));
  }

  // ── Context menu ──────────────────────────────────────────────────

  void _showContextMenu(Offset position) {
    _removeContextMenu();

    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    final menuWidth = isTablet ? 310.0 : 260.0;
    final menuHeight = isTablet ? 56.0 : 46.0;

    double left = position.dx - menuWidth / 2;
    double top = position.dy - menuHeight - 12;

    final minLeft = safePadding.left + 8;
    final maxLeft = screenSize.width - safePadding.right - menuWidth - 8;
    left = left.clamp(minLeft, maxLeft);

    if (top < safePadding.top + 8) top = position.dy + 12;
    if (top + menuHeight > screenSize.height - safePadding.bottom - 8) {
      top = screenSize.height - safePadding.bottom - menuHeight - 8;
    }

    final overlay = Overlay.of(context);
    _contextMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...highlightColors.entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      _highlightSelectedText(entry.key);
                      _removeContextMenu();
                    },
                    child: Container(
                      width: isTablet ? 36 : 30,
                      height: isTablet ? 36 : 30,
                      margin:
                          EdgeInsets.symmetric(horizontal: isTablet ? 5 : 4),
                      decoration: BoxDecoration(
                        color: entry.value.withValues(alpha: 1.0),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                }),
                Container(
                  width: 1,
                  height: isTablet ? 28 : 22,
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                GestureDetector(
                  onTap: () {
                    _underlineSelectedText();
                    _removeContextMenu();
                  },
                  child: Container(
                    width: isTablet ? 36 : 30,
                    height: isTablet ? 36 : 30,
                    margin:
                        EdgeInsets.symmetric(horizontal: isTablet ? 5 : 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.format_underlined,
                      size: isTablet ? 20 : 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _removeContextMenu();
                    _quickHighlightAndNote();
                  },
                  child: Container(
                    width: isTablet ? 36 : 30,
                    height: isTablet ? 36 : 30,
                    margin:
                        EdgeInsets.symmetric(horizontal: isTablet ? 5 : 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.note_add_outlined,
                      size: isTablet ? 20 : 16,
                      color: const Color(0xFF43A047),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_contextMenuOverlay!);
  }

  void _removeContextMenu() {
    _contextMenuDebounce?.cancel();
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
  }

  // ── Convert pdfrx selections to AnnotationTextBounds ───────────────
  //
  // PdfTextRanges uses PDF coordinates (bottom-left origin, Y-up).
  // We store bounds in the same coordinate system as Syncfusion
  // (top-left origin, Y-down). The `_boundsToScreenRect` method
  // handles the conversion at paint time using PdfRect.toRectInPageRect.
  // For storage we keep PDF-native coords — both viewers can consume them
  // via their own coord conversion.

  List<AnnotationTextBounds> _selectionToBounds(
      List<PdfTextRanges> selections) {
    final result = <AnnotationTextBounds>[];
    for (final sel in selections) {
      final pageNumber = sel.pageNumber;
      for (final range in sel.ranges) {
        final withFrags = range.toTextRangeWithFragments(sel.pageText);
        if (withFrags == null) continue;
        // Get per-fragment bounding rects for multi-line selections
        for (final frag in withFrags.fragments) {
          final b = frag.bounds;
          result.add(AnnotationTextBounds(
            left: b.left,
            top: b.top,
            width: b.right - b.left,
            height: b.top - b.bottom, // PDF coords: top > bottom
            text: frag.text,
            pageNumber: pageNumber,
          ));
        }
      }
    }
    return result;
  }

  // ── Highlight creation ────────────────────────────────────────────

  /// Returns the backend highlight_id on success, or null on failure.
  Future<String?> _highlightSelectedText(String color) async {
    // Use captured bounds (frozen at context menu show time) so that
    // selection clearing from the overlay tap doesn't lose data.
    final bounds = _capturedBounds ??
        (_currentSelections != null ? _selectionToBounds(_currentSelections!) : null);
    if (bounds == null || bounds.isEmpty) return null;

    final selectedText = _capturedText ?? _currentSelectedText ?? '';
    final highlightColor =
        highlightColors[color] ?? highlightColors['yellow']!;
    final firstPage = bounds.first.pageNumber;

    // Optimistic UI
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final data = _AnnotationData(bounds: bounds, color: highlightColor);
    _setAnnotationState(() {
      _highlights[tempId] = data;
      _annotationTexts[tempId] = selectedText;
      _annotationBounds[tempId] = bounds;
    });

    _currentSelections = null;
    _currentSelectedText = null;
    _capturedBounds = null;
    _capturedText = null;

    if (widget.documentId != null) {
      try {
        final boundsData = bounds.map((b) => b.toJson()).toList();
        final result = await _highlightService.addHighlight(
          documentId: widget.documentId!,
          pageNumber: firstPage,
          startOffset: bounds.first.left.toInt().abs(),
          endOffset: bounds.last.toRect().right.toInt().abs(),
          highlightedText: selectedText.length > 2000
              ? selectedText.substring(0, 2000)
              : selectedText,
          color: color,
          boundsData: boundsData,
        );

        final highlightId = result['highlight_id'] as String;
        _setAnnotationState(() {
          _highlights[highlightId] = _highlights.remove(tempId)!;
          _annotationNotes[highlightId] = null;
          _annotationTexts[highlightId] = _annotationTexts.remove(tempId)!;
          _annotationBounds[highlightId] = _annotationBounds.remove(tempId)!;
        });
        return highlightId;
      } catch (e) {
        debugPrint('Failed to save highlight: $e');
        _setAnnotationState(() {
          _highlights.remove(tempId);
          _annotationTexts.remove(tempId);
          _annotationBounds.remove(tempId);
        });
        if (mounted) {
          showAppDialog(context,
              message: 'Failed to save highlight', type: AppDialogType.info);
        }
        return null;
      }
    }
    return tempId;
  }

  Future<void> _quickHighlightAndNote() async {
    final highlightId = await _highlightSelectedText('yellow');
    if (highlightId != null && mounted) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _showNoteDialog(highlightId);
    }
  }

  // ── Underline creation + toggle ───────────────────────────────────

  bool _boundsOverlap(
      List<AnnotationTextBounds> a, List<AnnotationTextBounds> b) {
    for (final lineA in a) {
      for (final lineB in b) {
        if (lineA.pageNumber != lineB.pageNumber) continue;
        // Coordinate-system-agnostic overlap check using X-range intersection
        // (works regardless of Y-up vs Y-down origin since we only use left/width)
        final aLeft = lineA.left;
        final aRight = lineA.left + lineA.width;
        final bLeft = lineB.left;
        final bRight = lineB.left + lineB.width;
        if (aLeft < bRight && aRight > bLeft) return true;
      }
    }
    return false;
  }

  Future<void> _underlineSelectedText() async {
    final bounds = _capturedBounds ??
        (_currentSelections != null ? _selectionToBounds(_currentSelections!) : null);
    if (bounds == null || bounds.isEmpty) return;

    // Toggle: check overlap with existing underlines
    for (final entry in _underlines.entries) {
      final storedBounds = _annotationBounds[entry.key];
      if (storedBounds == null) continue;
      if (_boundsOverlap(bounds, storedBounds)) {
        _currentSelections = null;
        _currentSelectedText = null;
        _capturedBounds = null;
        _capturedText = null;
        _removeAnnotation(entry.key, isUnderline: true);
        return;
      }
    }

    final selectedText = _capturedText ?? _currentSelectedText ?? '';
    final firstPage = bounds.first.pageNumber;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final data = _AnnotationData(bounds: bounds, color: underlineColor);
    _setAnnotationState(() {
      _underlines[tempId] = data;
      _annotationTexts[tempId] = selectedText;
      _annotationBounds[tempId] = bounds;
    });

    _currentSelections = null;
    _currentSelectedText = null;
    _capturedBounds = null;
    _capturedText = null;

    if (widget.documentId != null) {
      try {
        final boundsData = bounds.map((b) => b.toJson()).toList();
        final result = await _highlightService.addHighlight(
          documentId: widget.documentId!,
          pageNumber: firstPage,
          startOffset: bounds.first.left.toInt().abs(),
          endOffset: bounds.last.toRect().right.toInt().abs(),
          highlightedText: selectedText.length > 2000
              ? selectedText.substring(0, 2000)
              : selectedText,
          color: 'blue',
          annotationType: 'underline',
          boundsData: boundsData,
        );

        final highlightId = result['highlight_id'] as String;
        _setAnnotationState(() {
          _underlines[highlightId] = _underlines.remove(tempId)!;
          _annotationNotes[highlightId] = null;
          _annotationTexts[highlightId] = _annotationTexts.remove(tempId)!;
          _annotationBounds[highlightId] = _annotationBounds.remove(tempId)!;
        });
      } catch (e) {
        debugPrint('Failed to save underline: $e');
        _setAnnotationState(() {
          _underlines.remove(tempId);
          _annotationTexts.remove(tempId);
          _annotationBounds.remove(tempId);
        });
        if (mounted) {
          showAppDialog(context,
              message: 'Failed to save underline', type: AppDialogType.info);
        }
      }
    }
  }

  // ── Annotation removal ────────────────────────────────────────────

  Future<void> _removeAnnotation(String annotationId,
      {bool isUnderline = false}) async {
    // Optimistic remove
    final removedHighlight = _highlights.remove(annotationId);
    final removedUnderline = _underlines.remove(annotationId);
    _annotationNotes.remove(annotationId);
    final removedText = _annotationTexts.remove(annotationId);
    final removedBounds = _annotationBounds.remove(annotationId);
    _setAnnotationState(() {});

    // Skip backend call for temp annotations (not yet persisted)
    if (annotationId.startsWith('temp_')) return;

    try {
      await _highlightService.deleteHighlight(annotationId);
    } catch (e) {
      debugPrint('Failed to delete annotation: $e');
      // Restore on failure
      if (mounted) {
        _setAnnotationState(() {
          if (removedHighlight != null) _highlights[annotationId] = removedHighlight;
          if (removedUnderline != null) _underlines[annotationId] = removedUnderline;
          if (removedText != null) _annotationTexts[annotationId] = removedText;
          if (removedBounds != null) _annotationBounds[annotationId] = removedBounds;
        });
        showAppDialog(context,
            message: 'Failed to remove annotation', type: AppDialogType.info);
      }
    }
  }

  // ── Annotation menu (bottom sheet) ────────────────────────────────

  void _showAnnotationMenu(String annotationId, bool isUnderline) {
    _removeContextMenu();

    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final hasNote = _annotationNotes[annotationId] != null;
    final noteText = hasNote ? _annotationNotes[annotationId] : null;
    final annotationText = _annotationTexts[annotationId];

    Color indicatorColor;
    if (isUnderline) {
      indicatorColor = underlineColor;
    } else {
      indicatorColor = (_highlights[annotationId]?.color ??
              highlightColors['yellow']!)
          .withValues(alpha: 1.0);
    }

    final bgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : Colors.grey[600]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isTablet ? 44 : 40,
                      height: isTablet ? 44 : 40,
                      decoration: BoxDecoration(
                        color: indicatorColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isUnderline
                              ? Icons.format_underlined
                              : Icons.border_color,
                          size: isTablet ? 22 : 20,
                          color: indicatorColor,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 14 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUnderline ? 'Underline' : 'Highlight',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 17 : 15,
                              color: textColor,
                            ),
                          ),
                          if (annotationText != null &&
                              annotationText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '"${annotationText.length > 80 ? '${annotationText.substring(0, 80)}...' : annotationText}"',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                color: subtitleColor,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 18 : 16),
              if (hasNote && noteText != null) ...[
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 14 : 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              AppColors.primaryBlue.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.sticky_note_2_outlined,
                            size: isTablet ? 18 : 16,
                            color: AppColors.primaryBlue),
                        SizedBox(width: isTablet ? 10 : 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('YOUR NOTE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet ? 11 : 10,
                                    color: AppColors.primaryBlue,
                                    letterSpacing: 0.8,
                                  )),
                              const SizedBox(height: 4),
                              Text(noteText,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 13,
                                    color: textColor,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 10),
              ],
              Divider(
                  height: 1,
                  color:
                      isDark ? AppColors.darkDivider : const Color(0xFFF0F0F0)),
              // Add/Edit Note
              InkWell(
                onTap: () {
                  Navigator.pop(sheetContext);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) _showNoteDialog(annotationId);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 16 : 14),
                  child: Row(
                    children: [
                      Container(
                        width: isTablet ? 36 : 32,
                        height: isTablet ? 36 : 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                            hasNote ? Icons.edit_note : Icons.note_add_outlined,
                            size: isTablet ? 20 : 18,
                            color: AppColors.primaryBlue),
                      ),
                      SizedBox(width: isTablet ? 14 : 12),
                      Text(hasNote ? 'Edit Note' : 'Add Note',
                          style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight: FontWeight.w500,
                              color: textColor)),
                      const Spacer(),
                      Icon(Icons.chevron_right,
                          size: isTablet ? 22 : 20, color: subtitleColor),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                indent: isTablet ? 70 : 64,
                endIndent: isTablet ? 24 : 20,
                color: isDark ? AppColors.darkDivider : const Color(0xFFF0F0F0),
              ),
              // Remove
              InkWell(
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeAnnotation(annotationId, isUnderline: isUnderline);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 16 : 14),
                  child: Row(
                    children: [
                      Container(
                        width: isTablet ? 36 : 32,
                        height: isTablet ? 36 : 32,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline,
                            size: isTablet ? 20 : 18, color: AppColors.error),
                      ),
                      SizedBox(width: isTablet ? 14 : 12),
                      Text(
                          isUnderline
                              ? 'Remove Underline'
                              : 'Remove Highlight',
                          style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
            ],
          ),
        );
      },
    );
  }

  // ── Note dialog ───────────────────────────────────────────────────

  void _showNoteDialog(String annotationId) {
    final existingNote = _annotationNotes[annotationId];
    final controller = TextEditingController(text: existingNote ?? '');
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);
    final annotationText = _annotationTexts[annotationId];

    final bgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                  child: Row(
                    children: [
                      Icon(
                          existingNote != null
                              ? Icons.edit_note
                              : Icons.note_add_outlined,
                          size: isTablet ? 24 : 22,
                          color: AppColors.primaryBlue),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(existingNote != null ? 'Edit Note' : 'Add Note',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 20 : 18,
                            color: textColor,
                          )),
                    ],
                  ),
                ),
                if (annotationText != null && annotationText.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 14 : 12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 20),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 14 : 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                            left: BorderSide(
                                color: AppColors.primaryBlue, width: 3)),
                      ),
                      child: Text(annotationText,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey[700],
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                SizedBox(height: isTablet ? 16 : 14),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    maxLength: 500,
                    autofocus: true,
                    style: TextStyle(
                        color: textColor,
                        fontSize: isTablet ? 15 : 14,
                        height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : Colors.grey[400],
                        fontSize: isTablet ? 15 : 14,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF8F9FE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 1.5),
                      ),
                      counterStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : Colors.grey,
                          fontSize: 11),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 18 : 14),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                  child: Row(
                    children: [
                      if (existingNote != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _saveAnnotationNote(annotationId, null);
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Remove'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text('Cancel',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.blueGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              final note = controller.text.trim();
                              _saveAnnotationNote(
                                  annotationId, note.isEmpty ? null : note);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 28 : 24,
                                  vertical: isTablet ? 12 : 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check,
                                      size: isTablet ? 18 : 16,
                                      color: Colors.white),
                                  SizedBox(width: isTablet ? 6 : 4),
                                  Text('Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 15 : 14,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAnnotationNote(String annotationId, String? note) async {
    try {
      await _highlightService.updateHighlightNote(annotationId, note);
      if (mounted) {
        setState(() => _annotationNotes[annotationId] = note);
      }
    } catch (e) {
      debugPrint('Failed to save note: $e');
      if (mounted) {
        showAppDialog(context,
            message: 'Failed to save note', type: AppDialogType.info);
      }
    }
  }

  // ── All notes panel ───────────────────────────────────────────────

  void _showAllNotesPanel() {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);
    final bgColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : Colors.grey[600]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final allIds = [..._highlights.keys, ..._underlines.keys];
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                  child: Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: isTablet ? 24 : 22,
                          color: AppColors.primaryBlue),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text('Your Notes & Highlights',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 20 : 18,
                            color: textColor,
                          )),
                      const Spacer(),
                      Text('${allIds.length}',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 10),
                Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkDivider
                        : const Color(0xFFF0F0F0)),
                Expanded(
                  child: allIds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.note_alt_outlined,
                                  size: isTablet ? 48 : 40,
                                  color: subtitleColor),
                              SizedBox(height: isTablet ? 12 : 8),
                              Text('No highlights or notes yet',
                                  style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: subtitleColor)),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text('Long press on text to highlight it',
                                  style: TextStyle(
                                      fontSize: isTablet ? 13 : 12,
                                      color: subtitleColor)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 10 : 8),
                          itemCount: allIds.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: isTablet ? 70 : 60,
                            endIndent: isTablet ? 24 : 20,
                            color: isDark
                                ? AppColors.darkDivider
                                : const Color(0xFFF0F0F0),
                          ),
                          itemBuilder: (context, index) {
                            final id = allIds[index];
                            final isHighlight = _highlights.containsKey(id);
                            final highlightedText =
                                _annotationTexts[id] ?? '';
                            final note = _annotationNotes[id];
                            final hasNote =
                                note != null && note.isNotEmpty;

                            Color accentColor;
                            if (!isHighlight) {
                              accentColor = underlineColor;
                            } else {
                              accentColor = (_highlights[id]?.color ??
                                      highlightColors['yellow']!)
                                  .withValues(alpha: 1.0);
                            }

                            return InkWell(
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  if (mounted) _showNoteDialog(id);
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24 : 20,
                                    vertical: isTablet ? 14 : 12),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: isTablet ? 36 : 30,
                                      height: isTablet ? 36 : 30,
                                      margin: EdgeInsets.only(
                                          right: isTablet ? 14 : 10),
                                      decoration: BoxDecoration(
                                        color: accentColor
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isHighlight
                                            ? Icons.border_color
                                            : Icons.format_underlined,
                                        size: isTablet ? 18 : 16,
                                        color: accentColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(highlightedText,
                                              style: TextStyle(
                                                fontSize: isTablet ? 14 : 13,
                                                color: textColor,
                                                fontStyle: FontStyle.italic,
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          if (hasNote) ...[
                                            SizedBox(
                                                height: isTablet ? 6 : 4),
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .sticky_note_2_outlined,
                                                    size: isTablet ? 14 : 12,
                                                    color: AppColors
                                                        .primaryBlue),
                                                SizedBox(
                                                    width:
                                                        isTablet ? 6 : 4),
                                                Expanded(
                                                  child: Text(note,
                                                      style: TextStyle(
                                                        fontSize: isTablet
                                                            ? 13
                                                            : 12,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        height: 1.3,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                          ] else ...[
                                            SizedBox(
                                                height: isTablet ? 4 : 2),
                                            Text('Tap to add note',
                                                style: TextStyle(
                                                  fontSize:
                                                      isTablet ? 12 : 11,
                                                  color: subtitleColor,
                                                )),
                                          ],
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _removeAnnotation(id,
                                            isUnderline: !isHighlight);
                                        Navigator.pop(sheetContext);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: isTablet ? 8 : 6),
                                        child: Icon(Icons.delete_outline,
                                            size: isTablet ? 22 : 20,
                                            color: AppColors.error
                                                .withValues(alpha: 0.7)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Search ────────────────────────────────────────────────────────

  void _toggleSearch() {
    setState(() => _isSearchOpen = !_isSearchOpen);
    if (!_isSearchOpen) {
      _textSearcher?.resetTextSearch();
      _searchController.clear();
    }
  }

  // ── Selection guard for bottom bar ────────────────────────────────

  void _requireSelectionOr(VoidCallback action) {
    // Also check captured bounds (from context menu) in case live selection cleared
    final hasSelection = (_currentSelections != null && _currentSelections!.isNotEmpty) ||
        (_capturedBounds != null && _capturedBounds!.isNotEmpty);
    if (!hasSelection) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Select text first by long-pressing on it'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
        );
      return;
    }
    action();
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isTablet = ResponsiveHelper.isTablet(context);

    final backgroundColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final toolbarColor = isDark ? AppColors.darkCardBackground : Colors.white;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      endDrawer: widget.documentId != null
          ? BookmarksDrawer(
              bookmarkedPages: _bookmarkedPages,
              bookmarkNotes: _bookmarkNotes,
              isDark: isDark,
              isTablet: isTablet,
              onJumpToPage: (page) {
                _scaffoldKey.currentState?.closeEndDrawer();
                _pdfController.goToPage(pageNumber: page);
              },
              onDeleteBookmark: (bookmarkId, pageNumber) async {
                try {
                  await _bookmarkService.deleteBookmark(bookmarkId);
                  if (mounted) {
                    setState(() {
                      _bookmarkedPages.remove(pageNumber);
                      _bookmarkNotes.remove(bookmarkId);
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    showAppDialog(context,
                        message: 'Failed to delete bookmark',
                        type: AppDialogType.info);
                  }
                }
              },
              onUpdateNote: (bookmarkId, note) async {
                try {
                  await _bookmarkService.updateBookmarkNote(bookmarkId, note);
                  if (mounted) {
                    setState(() => _bookmarkNotes[bookmarkId] = note);
                  }
                } catch (e) {
                  if (mounted) {
                    showAppDialog(context,
                        message: 'Failed to update bookmark note',
                        type: AppDialogType.info);
                  }
                }
              },
            )
          : null,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: toolbarColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.transparent),
      ),
      body: _error != null
          ? _buildErrorView(isTablet, textColor)
          : _isLoading
              ? _buildLoadingView(isTablet)
              : Stack(
                  children: [
                    Column(
                      children: [
                        _buildToolbar(isDark, textColor, toolbarColor, isTablet),
                        Expanded(child: _buildPdfViewer()),
                        if (_isPdfReady)
                          _buildBottomActionBar(isDark, isTablet),
                      ],
                    ),
                    if (!_isPdfReady)
                      Positioned.fill(
                        child: Container(
                          color: isDark
                              ? AppColors.darkBackground
                              : Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryBlue),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildPdfViewer() {
    // Cache the viewer so setState never recreates it (which would reset
    // the document, scroll position, and internal pdfrx state).
    // Annotation repaints are triggered via _pdfController.invalidate().
    _cachedPdfViewer ??= PdfViewer.file(
      _localPath!,
      controller: _pdfController,
      params: PdfViewerParams(
        enableTextSelection: true,
        // Suppress native copy/share/search toolbar on text selection
        selectableRegionInjector: (context, child) => SelectionArea(
          contextMenuBuilder: (context, selectableRegionState) =>
              const SizedBox.shrink(),
          child: child,
        ),
        viewerOverlayBuilder: (context, size, handleLinkTap) => [
          PdfViewerScrollThumb(
            controller: _pdfController,
            orientation: ScrollbarOrientation.right,
          ),
        ],
        pagePaintCallbacks: [
          _paintAnnotations,
          if (_textSearcher != null)
            _textSearcher!.pageTextMatchPaintCallback,
        ],
        pageOverlaysBuilder: _buildPageOverlays,
        onPageChanged: (pageNumber) {
          if (pageNumber != null) {
            _currentPage.value = pageNumber;
            _debouncedSaveProgress(pageNumber);
          }
        },
        onDocumentChanged: (document) {
          if (document != null && !_isPdfReady) {
            setState(() => _isPdfReady = true);
            _textSearcher = PdfTextSearcher(_pdfController);
            _loadHighlights();
            _loadBookmarks();
            _restoreProgress();
          }
        },
        onTextSelectionChange: _handleTextSelectionChange,
      ),
    );

    if (_isPdfDarkMode) {
      return ColorFiltered(
          colorFilter: _invertColorFilter, child: _cachedPdfViewer!);
    }
    return _cachedPdfViewer!;
  }

  // ── Toolbar ───────────────────────────────────────────────────────

  Widget _buildToolbar(
      bool isDark, Color textColor, Color toolbarColor, bool isTablet) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: toolbarColor,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: isTablet ? 44 : 36,
                    height: isTablet ? 44 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF5F5F5),
                    ),
                    child: Icon(Icons.arrow_back,
                        size: isTablet ? 22 : 18, color: textColor),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: Text(widget.title,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 18 : 15,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (widget.documentId != null) ...[
                  ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (context, currentPage, _) {
                      final isBookmarked =
                          _bookmarkedPages.containsKey(currentPage);
                      return GestureDetector(
                        onTap: _toggleBookmark,
                        child: Container(
                          width: isTablet ? 44 : 36,
                          height: isTablet ? 44 : 36,
                          margin: EdgeInsets.only(right: isTablet ? 4 : 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isBookmarked
                                ? AppColors.primaryBlue
                                    .withValues(alpha: 0.1)
                                : (isDark
                                    ? AppColors.darkSurface
                                    : const Color(0xFFF5F5F5)),
                          ),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: isTablet ? 22 : 18,
                            color: isBookmarked
                                ? AppColors.primaryBlue
                                : textColor,
                          ),
                        ),
                      );
                    },
                  ),
                  if (_bookmarkedPages.isNotEmpty)
                    GestureDetector(
                      onTap: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                      child: Container(
                        width: isTablet ? 44 : 36,
                        height: isTablet ? 44 : 36,
                        margin: EdgeInsets.only(right: isTablet ? 4 : 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.darkSurface
                              : const Color(0xFFF5F5F5),
                        ),
                        child: Icon(Icons.collections_bookmark_outlined,
                            size: isTablet ? 22 : 18, color: textColor),
                      ),
                    ),
                ],
                GestureDetector(
                  onTap: () =>
                      setState(() => _isPdfDarkMode = !_isPdfDarkMode),
                  child: Container(
                    width: isTablet ? 44 : 36,
                    height: isTablet ? 44 : 36,
                    margin: EdgeInsets.only(right: isTablet ? 4 : 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPdfDarkMode
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : (isDark
                              ? AppColors.darkSurface
                              : const Color(0xFFF5F5F5)),
                    ),
                    child: Icon(
                      _isPdfDarkMode ? Icons.light_mode : Icons.dark_mode,
                      size: isTablet ? 22 : 18,
                      color:
                          _isPdfDarkMode ? AppColors.primaryBlue : textColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _toggleSearch,
                  child: Container(
                    width: isTablet ? 44 : 36,
                    height: isTablet ? 44 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isSearchOpen
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : (isDark
                              ? AppColors.darkSurface
                              : const Color(0xFFF5F5F5)),
                    ),
                    child: Icon(
                      _isSearchOpen ? Icons.close : Icons.search,
                      size: isTablet ? 22 : 18,
                      color:
                          _isSearchOpen ? AppColors.primaryBlue : textColor,
                    ),
                  ),
                ),
              ],
            ),
            if (_isSearchOpen) ...[
              SizedBox(height: isTablet ? 10 : 8),
              _buildSearchBar(isDark, textColor, isTablet),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color textColor, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(fontSize: isTablet ? 16 : 14, color: textColor),
            decoration: InputDecoration(
              hintText: 'Search in document...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                fontSize: isTablet ? 16 : 14,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 12 : 10,
              ),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty && _textSearcher != null) {
                _textSearcher!.startTextSearch(value);
              }
            },
          ),
        ),
        if (_textSearcher != null) ...[
          SizedBox(width: isTablet ? 8 : 4),
          GestureDetector(
            onTap: () => _textSearcher?.goToPrevMatch(),
            child: Icon(Icons.keyboard_arrow_up,
                size: isTablet ? 28 : 24, color: textColor),
          ),
          GestureDetector(
            onTap: () => _textSearcher?.goToNextMatch(),
            child: Icon(Icons.keyboard_arrow_down,
                size: isTablet ? 28 : 24, color: textColor),
          ),
        ],
      ],
    );
  }

  // ── Bottom action bar ─────────────────────────────────────────────

  Widget _buildBottomActionBar(bool isDark, bool isTablet) {
    final barColor = isDark ? AppColors.darkCardBackground : Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: barColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomAction(
              icon: Icons.border_color,
              label: 'Highlight',
              color: const Color(0xFFFFEB3B),
              onTap: () =>
                  _requireSelectionOr(() => _highlightSelectedText('yellow')),
              isDark: isDark,
              isTablet: isTablet,
            ),
            _buildBottomAction(
              icon: Icons.format_underlined,
              label: 'Underline',
              color: const Color(0xFF1565C0),
              onTap: () => _requireSelectionOr(_underlineSelectedText),
              isDark: isDark,
              isTablet: isTablet,
            ),
            _buildBottomAction(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notes',
              color: const Color(0xFF43A047),
              onTap: _showAllNotesPanel,
              isDark: isDark,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 4 : 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: isTablet ? 20 : 16, color: color),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(label,
                style: TextStyle(
                  fontSize: isTablet ? 11 : 9,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.darkTextSecondary : Colors.grey[700],
                )),
          ],
        ),
      ),
    );
  }

  // ── Error / Loading views ─────────────────────────────────────────

  Widget _buildErrorView(bool isTablet, Color textColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: isTablet ? 64 : 48, color: Colors.grey),
          SizedBox(height: isTablet ? 21 : 16),
          Text(_error!,
              style:
                  TextStyle(fontSize: isTablet ? 20 : 16, color: textColor)),
          SizedBox(height: isTablet ? 21 : 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
                _isLoading = true;
                _isPdfReady = false;
                _downloadProgress = 0;
                _cachedPdfViewer = null;
                _highlightsLoaded = false;
                _bookmarksLoaded = false;
              });
              _loadPdf();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(bool isTablet) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
              value: _downloadProgress > 0 ? _downloadProgress : null),
          if (_downloadProgress > 0) ...[
            SizedBox(height: isTablet ? 21 : 16),
            Text('${(_downloadProgress * 100).toInt()}%',
                style: TextStyle(
                    fontSize: isTablet ? 17 : 14, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
