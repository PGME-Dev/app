import 'package:json_annotation/json_annotation.dart';
import 'package:pgme/core/models/document_model.dart';

part 'library_model.g.dart';

@JsonSerializable()
class LibraryModel {
  @JsonKey(name: 'library_id')
  final String libraryId;

  final DocumentModel document;

  final SeriesInfo? series;

  @JsonKey(name: 'added_at')
  final String addedAt;

  LibraryModel({
    required this.libraryId,
    required this.document,
    this.series,
    required this.addedAt,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) =>
      _$LibraryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryModelToJson(this);

  LibraryModel copyWith({
    String? libraryId,
    DocumentModel? document,
    SeriesInfo? series,
    String? addedAt,
  }) {
    return LibraryModel(
      libraryId: libraryId ?? this.libraryId,
      document: document ?? this.document,
      series: series ?? this.series,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

@JsonSerializable()
class SeriesInfo {
  @JsonKey(name: 'series_id')
  final String seriesId;

  final String title;

  SeriesInfo({
    required this.seriesId,
    required this.title,
  });

  factory SeriesInfo.fromJson(Map<String, dynamic> json) =>
      _$SeriesInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesInfoToJson(this);
}
