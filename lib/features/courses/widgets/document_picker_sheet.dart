import 'package:flutter/material.dart';
import 'package:pgme/core/models/ebook_access_model.dart';
import 'package:pgme/core/models/library_item_model.dart';
import 'package:pgme/core/models/selectable_document.dart';
import 'package:pgme/core/services/dashboard_service.dart';
import 'package:pgme/core/services/ebook_access_service.dart';

/// Modal bottom sheet that shows the user's accessible documents (library
/// notes + purchased ebooks) and lets them pick one to open inline.
class DocumentPickerSheet extends StatefulWidget {
  final void Function(SelectableDocument) onDocumentSelected;

  const DocumentPickerSheet({
    super.key,
    required this.onDocumentSelected,
  });

  @override
  State<DocumentPickerSheet> createState() => _DocumentPickerSheetState();
}

class _DocumentPickerSheetState extends State<DocumentPickerSheet> {
  List<SelectableDocument> _libraryDocs = [];
  List<SelectableDocument> _ebookDocs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        DashboardService().getUserLibrary(),
        EbookAccessService().getUserAccessibleEbooks(),
      ]);

      final libraryItems = results[0] as List<LibraryItemModel>;
      final ebooks = results[1] as List<EbookAccessModel>;

      if (!mounted) return;

      setState(() {
        _libraryDocs = libraryItems
            .where((item) =>
                item.fileFormat.toLowerCase() == 'pdf')
            .map((item) => SelectableDocument.fromLibraryItem(item))
            .toList();

        _ebookDocs = ebooks
            .where((ebook) =>
                (ebook.ebookFileFormat ?? 'pdf').toLowerCase() == 'pdf')
            .map((ebook) => SelectableDocument.fromEbook(ebook))
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Open a document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white54))
                    : _error != null
                        ? _buildError()
                        : _libraryDocs.isEmpty && _ebookDocs.isEmpty
                            ? _buildEmpty()
                            : _buildList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white38, size: 40),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Failed to load documents',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadDocuments,
              child: const Text('Retry',
                  style: TextStyle(color: Color(0xFF00BEFA))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'No documents available',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Add notes to your library or purchase ebooks to see them here.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (_libraryDocs.isNotEmpty) ...[
          _buildSectionHeader('My Notes', _libraryDocs.length),
          ..._libraryDocs.map(_buildDocumentTile),
        ],
        if (_ebookDocs.isNotEmpty) ...[
          if (_libraryDocs.isNotEmpty) const SizedBox(height: 8),
          _buildSectionHeader('My eBooks', _ebookDocs.length),
          ..._ebookDocs.map(_buildDocumentTile),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDocumentTile(SelectableDocument doc) {
    final subtitle = [
      doc.pageCountText,
      doc.formattedFileSize,
    ].where((s) => s.isNotEmpty).join('  •  ');

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          doc.source == DocumentSource.library
              ? Icons.description
              : Icons.menu_book,
          color: Colors.white38,
          size: 20,
        ),
      ),
      title: Text(
        doc.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () {
        Navigator.of(context).pop();
        widget.onDocumentSelected(doc);
      },
    );
  }
}
