// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryItemModel _$LibraryItemModelFromJson(Map<String, dynamic> json) =>
    LibraryItemModel(
      libraryId: json['library_id'] as String,
      documentId: json['document_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileFormat: json['file_format'] as String? ?? 'pdf',
      fileUrl: json['file_url'] as String?,
      pageCount: (json['page_count'] as num?)?.toInt(),
      previewUrl: json['preview_url'] as String?,
      fileSizeMb: (json['file_size_mb'] as num?)?.toDouble(),
      addedAt: json['added_at'] as String?,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      notes: json['notes'] as String?,
      lastOpenedAt: json['last_opened_at'] as String?,
      subjectId: json['subject_id'] as String?,
    );

Map<String, dynamic> _$LibraryItemModelToJson(LibraryItemModel instance) =>
    <String, dynamic>{
      'library_id': instance.libraryId,
      'document_id': instance.documentId,
      'title': instance.title,
      'description': instance.description,
      'file_format': instance.fileFormat,
      'file_url': instance.fileUrl,
      'page_count': instance.pageCount,
      'preview_url': instance.previewUrl,
      'file_size_mb': instance.fileSizeMb,
      'added_at': instance.addedAt,
      'is_bookmarked': instance.isBookmarked,
      'notes': instance.notes,
      'last_opened_at': instance.lastOpenedAt,
      'subject_id': instance.subjectId,
    };
