import 'package:pgme/core/models/ebook_access_model.dart';
import 'package:pgme/core/models/library_item_model.dart';

enum DocumentSource { library, ebook }

/// Unified document type used by the document picker and inline PDF viewer.
/// Wraps both [LibraryItemModel] (user's saved notes) and [EbookAccessModel]
/// (purchased ebooks) into a single type.
class SelectableDocument {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final int? pageCount;
  final double? fileSizeMb;
  final DocumentSource source;

  const SelectableDocument({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    this.pageCount,
    this.fileSizeMb,
    required this.source,
  });

  factory SelectableDocument.fromLibraryItem(LibraryItemModel item) {
    return SelectableDocument(
      id: item.documentId,
      title: item.title,
      thumbnailUrl: item.previewUrl,
      pageCount: item.pageCount,
      fileSizeMb: item.fileSizeMb,
      source: DocumentSource.library,
    );
  }

  factory SelectableDocument.fromEbook(EbookAccessModel ebook) {
    return SelectableDocument(
      id: ebook.bookId,
      title: ebook.title,
      thumbnailUrl: ebook.thumbnailUrl,
      pageCount: ebook.pages,
      fileSizeMb: ebook.ebookFileSizeMb,
      source: DocumentSource.ebook,
    );
  }

  String get formattedFileSize {
    if (fileSizeMb == null) return '';
    if (fileSizeMb! < 1) {
      return '${(fileSizeMb! * 1024).toStringAsFixed(0)} KB';
    }
    return '${fileSizeMb!.toStringAsFixed(1)} MB';
  }

  String get pageCountText {
    if (pageCount == null) return '';
    return '$pageCount ${pageCount == 1 ? 'page' : 'pages'}';
  }
}
