// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      documentId: json['document_id'] as String,
      title: json['title'] as String,
      documentType: json['document_type'] as String,
      fileUrl: json['file_url'] as String,
      fileSizeMb: (json['file_size_mb'] as num).toDouble(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'document_id': instance.documentId,
      'title': instance.title,
      'document_type': instance.documentType,
      'file_url': instance.fileUrl,
      'file_size_mb': instance.fileSizeMb,
      'thumbnail_url': instance.thumbnailUrl,
      'description': instance.description,
    };
