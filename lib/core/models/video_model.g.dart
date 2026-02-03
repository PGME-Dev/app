// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      moduleTitle: json['module_title'] as String?,
      positionSeconds: (json['position_seconds'] as num).toInt(),
      watchPercentage: (json['watch_percentage'] as num).toInt(),
      completed: json['completed'] as bool,
      lastAccessedAt: json['last_accessed_at'] as String?,
    );

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'video_id': instance.videoId,
      'title': instance.title,
      'thumbnail_url': instance.thumbnailUrl,
      'duration_seconds': instance.durationSeconds,
      'module_title': instance.moduleTitle,
      'position_seconds': instance.positionSeconds,
      'watch_percentage': instance.watchPercentage,
      'completed': instance.completed,
      'last_accessed_at': instance.lastAccessedAt,
    };
