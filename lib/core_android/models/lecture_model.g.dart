// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LectureModel _$LectureModelFromJson(Map<String, dynamic> json) => LectureModel(
      lectureId: json['lecture_id'] as String,
      title: json['title'] as String,
      videoUrl: json['video_url'] as String?,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      description: json['description'] as String?,
      sequenceNumber: (json['sequence_number'] as num?)?.toInt() ?? 0,
      isFree: json['is_free'] as bool? ?? false,
    );

Map<String, dynamic> _$LectureModelToJson(LectureModel instance) =>
    <String, dynamic>{
      'lecture_id': instance.lectureId,
      'title': instance.title,
      'video_url': instance.videoUrl,
      'duration_minutes': instance.durationMinutes,
      'thumbnail_url': instance.thumbnailUrl,
      'description': instance.description,
      'sequence_number': instance.sequenceNumber,
      'is_free': instance.isFree,
    };
