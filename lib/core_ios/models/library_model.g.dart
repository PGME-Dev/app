// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryModel _$LibraryModelFromJson(Map<String, dynamic> json) => LibraryModel(
      libraryId: json['library_id'] as String,
      document:
          DocumentModel.fromJson(json['document'] as Map<String, dynamic>),
      series: json['series'] == null
          ? null
          : SeriesInfo.fromJson(json['series'] as Map<String, dynamic>),
      addedAt: json['added_at'] as String,
    );

Map<String, dynamic> _$LibraryModelToJson(LibraryModel instance) =>
    <String, dynamic>{
      'library_id': instance.libraryId,
      'document': instance.document,
      'series': instance.series,
      'added_at': instance.addedAt,
    };

SeriesInfo _$SeriesInfoFromJson(Map<String, dynamic> json) => SeriesInfo(
      seriesId: json['series_id'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$SeriesInfoToJson(SeriesInfo instance) =>
    <String, dynamic>{
      'series_id': instance.seriesId,
      'title': instance.title,
    };
