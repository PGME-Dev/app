import 'package:json_annotation/json_annotation.dart';

part 'library_item_model.g.dart';

@JsonSerializable()
class LibraryItemModel {
  @JsonKey(name: 'library_id')
  final String libraryId;

  @JsonKey(name: 'document_id')
  final String documentId;

  final String title;

  final String? description;

  @JsonKey(name: 'file_format', defaultValue: 'pdf')
  final String fileFormat;

  @JsonKey(name: 'file_url')
  final String? fileUrl;

  @JsonKey(name: 'page_count')
  final int? pageCount;

  @JsonKey(name: 'preview_url')
  final String? previewUrl;

  @JsonKey(name: 'file_size_mb')
  final double? fileSizeMb;

  @JsonKey(name: 'added_at')
  final String? addedAt;

  @JsonKey(name: 'is_bookmarked', defaultValue: false)
  final bool isBookmarked;

  final String? notes;

  @JsonKey(name: 'last_opened_at')
  final String? lastOpenedAt;

  @JsonKey(name: 'subject_id')
  final String? subjectId;

  LibraryItemModel({
    required this.libraryId,
    required this.documentId,
    required this.title,
    this.description,
    this.fileFormat = 'pdf',
    this.fileUrl,
    this.pageCount,
    this.previewUrl,
    this.fileSizeMb,
    this.addedAt,
    this.isBookmarked = false,
    this.notes,
    this.lastOpenedAt,
    this.subjectId,
  });

  factory LibraryItemModel.fromJson(Map<String, dynamic> json) =>
      _$LibraryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryItemModelToJson(this);

  LibraryItemModel copyWith({bool? isBookmarked}) {
    return LibraryItemModel(
      libraryId: libraryId,
      documentId: documentId,
      title: title,
      description: description,
      fileFormat: fileFormat,
      fileUrl: fileUrl,
      pageCount: pageCount,
      previewUrl: previewUrl,
      fileSizeMb: fileSizeMb,
      addedAt: addedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      notes: notes,
      lastOpenedAt: lastOpenedAt,
      subjectId: subjectId,
    );
  }

  // Computed property for formatted file size
  String get formattedFileSize {
    if (fileSizeMb == null) return 'N/A';
    if (fileSizeMb! < 1) {
      return '${(fileSizeMb! * 1024).toStringAsFixed(0)} KB';
    }
    return '${fileSizeMb!.toStringAsFixed(1)} MB';
  }

  // Computed property for file extension
  String get fileExtension {
    return fileFormat.toUpperCase();
  }

  // Computed property for page count text
  String get pageCountText {
    if (pageCount == null) return 'N/A';
    return '$pageCount ${pageCount == 1 ? 'Page' : 'Pages'}';
  }

  // Computed property for formatted date
  String get formattedAddedDate {
    if (addedAt == null) return '';
    try {
      final dateTime = DateTime.parse(addedAt!);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return addedAt!;
    }
  }
}
