// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    ProgressModel(
      progressId: json['progress_id'] as String,
      lecture: LectureModel.fromJson(json['lecture'] as Map<String, dynamic>),
      watchTimeSeconds: (json['watch_time_seconds'] as num).toInt(),
      lastWatchedPositionSeconds:
          (json['last_watched_position_seconds'] as num).toInt(),
      isCompleted: json['is_completed'] as bool? ?? false,
      completionPercentage: (json['completion_percentage'] as num).toInt(),
      lastWatchedAt: json['last_watched_at'] as String,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$ProgressModelToJson(ProgressModel instance) =>
    <String, dynamic>{
      'progress_id': instance.progressId,
      'lecture': instance.lecture,
      'watch_time_seconds': instance.watchTimeSeconds,
      'last_watched_position_seconds': instance.lastWatchedPositionSeconds,
      'is_completed': instance.isCompleted,
      'completion_percentage': instance.completionPercentage,
      'last_watched_at': instance.lastWatchedAt,
      'createdAt': instance.createdAt,
    };
