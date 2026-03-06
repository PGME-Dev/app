import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

@JsonSerializable()
class DocumentModel {
  @JsonKey(name: 'document_id')
  final String documentId;

  final String title;

  @JsonKey(name: 'document_type')
  final String documentType; // "pdf", "notes", "handout"

  @JsonKey(name: 'file_url')
  final String fileUrl;

  @JsonKey(name: 'file_size_mb')
  final double fileSizeMb;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  final String? description;

  DocumentModel({
    required this.documentId,
    required this.title,
    required this.documentType,
    required this.fileUrl,
    required this.fileSizeMb,
    this.thumbnailUrl,
    this.description,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);

  DocumentModel copyWith({
    String? documentId,
    String? title,
    String? documentType,
    String? fileUrl,
    double? fileSizeMb,
    String? thumbnailUrl,
    String? description,
  }) {
    return DocumentModel(
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSizeMb: fileSizeMb ?? this.fileSizeMb,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
    );
  }

  // Formatted file size
  String get formattedFileSize => '${fileSizeMb.toStringAsFixed(1)} MB';
}
