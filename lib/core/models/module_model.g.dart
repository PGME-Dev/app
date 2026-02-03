// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModuleVideoModel _$ModuleVideoModelFromJson(Map<String, dynamic> json) =>
    ModuleVideoModel(
      videoId: json['video_id'] as String,
      title: json['title'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      facultyName: json['faculty_name'] as String,
      facultyId: json['faculty_id'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ModuleVideoModelToJson(ModuleVideoModel instance) =>
    <String, dynamic>{
      'video_id': instance.videoId,
      'title': instance.title,
      'duration_seconds': instance.durationSeconds,
      'faculty_name': instance.facultyName,
      'faculty_id': instance.facultyId,
      'is_completed': instance.isCompleted,
      'is_locked': instance.isLocked,
      'is_free': instance.isFree,
      'display_order': instance.displayOrder,
    };

ModuleModel _$ModuleModelFromJson(Map<String, dynamic> json) => ModuleModel(
      moduleId: json['module_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      lessonCount: (json['lesson_count'] as num?)?.toInt() ?? 0,
      completedLessons: (json['completed_lessons'] as num?)?.toInt() ?? 0,
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toInt(),
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => ModuleVideoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isLocked: json['is_locked'] as bool? ?? false,
    );

Map<String, dynamic> _$ModuleModelToJson(ModuleModel instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'name': instance.name,
      'description': instance.description,
      'display_order': instance.displayOrder,
      'lesson_count': instance.lessonCount,
      'completed_lessons': instance.completedLessons,
      'estimated_duration_minutes': instance.estimatedDurationMinutes,
      'videos': instance.videos,
      'is_locked': instance.isLocked,
    };
