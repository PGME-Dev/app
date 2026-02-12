import 'package:json_annotation/json_annotation.dart';

part 'module_model.g.dart';

@JsonSerializable()
class ModuleVideoModel {
  @JsonKey(name: 'video_id')
  final String videoId;

  final String title;

  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;

  @JsonKey(name: 'faculty_name', defaultValue: '')
  final String facultyName;

  @JsonKey(name: 'faculty_id')
  final String? facultyId;

  @JsonKey(name: 'is_completed', defaultValue: false)
  final bool isCompleted;

  @JsonKey(name: 'is_locked', defaultValue: false)
  final bool isLocked;

  @JsonKey(name: 'is_free', defaultValue: false)
  final bool isFree;

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  ModuleVideoModel({
    required this.videoId,
    required this.title,
    required this.durationSeconds,
    this.facultyName = '',
    this.facultyId,
    this.isCompleted = false,
    this.isLocked = false,
    this.isFree = false,
    this.displayOrder = 0,
  });

  factory ModuleVideoModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleVideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleVideoModelToJson(this);

  // Computed property for formatted duration (MM:SS or HH:MM:SS)
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

@JsonSerializable()
class ModuleModel {
  @JsonKey(name: 'module_id')
  final String moduleId;

  final String name;

  final String? description;

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  @JsonKey(name: 'lesson_count', defaultValue: 0)
  final int lessonCount;

  @JsonKey(name: 'completed_lessons', defaultValue: 0)
  final int completedLessons;

  @JsonKey(name: 'estimated_duration_minutes')
  final int? estimatedDurationMinutes;

  @JsonKey(name: 'videos', defaultValue: [])
  final List<ModuleVideoModel> videos;

  @JsonKey(name: 'is_locked', defaultValue: false)
  final bool isLocked;

  ModuleModel({
    required this.moduleId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    this.lessonCount = 0,
    this.completedLessons = 0,
    this.estimatedDurationMinutes,
    this.videos = const [],
    this.isLocked = false,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleModelToJson(this);

  // Computed property for completion percentage
  double get completionPercentage {
    if (lessonCount == 0) return 0.0;
    return (completedLessons / lessonCount) * 100;
  }

  // Computed property for formatted duration
  String get formattedDuration {
    if (estimatedDurationMinutes == null) return 'N/A';
    final hours = estimatedDurationMinutes! ~/ 60;
    final minutes = estimatedDurationMinutes! % 60;
    if (hours > 0) {
      return '$hours hrs ${minutes > 0 ? "$minutes mins" : ""}';
    }
    return '$minutes mins';
  }
}
