import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  @JsonKey(name: 'video_id')
  final String videoId;

  final String title;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;

  @JsonKey(name: 'module_title')
  final String? moduleTitle;

  @JsonKey(name: 'position_seconds')
  final int positionSeconds;

  @JsonKey(name: 'watch_percentage')
  final int watchPercentage;

  final bool completed;

  @JsonKey(name: 'last_accessed_at')
  final String? lastAccessedAt;

  @JsonKey(name: 'is_free', defaultValue: false)
  final bool isFree;

  VideoModel({
    required this.videoId,
    required this.title,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.moduleTitle,
    required this.positionSeconds,
    required this.watchPercentage,
    required this.completed,
    this.lastAccessedAt,
    required this.isFree,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  // Computed property for remaining time
  int get remainingSeconds => durationSeconds - positionSeconds;

  // Get remaining time in minutes (rounded up)
  int get remainingMinutes => (remainingSeconds / 60).ceil();

  VideoModel copyWith({
    String? videoId,
    String? title,
    String? thumbnailUrl,
    int? durationSeconds,
    String? moduleTitle,
    int? positionSeconds,
    int? watchPercentage,
    bool? completed,
    String? lastAccessedAt,
    bool? isFree,
  }) {
    return VideoModel(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      watchPercentage: watchPercentage ?? this.watchPercentage,
      completed: completed ?? this.completed,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isFree: isFree ?? this.isFree,
    );
  }
}
