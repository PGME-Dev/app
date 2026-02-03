import 'package:json_annotation/json_annotation.dart';
import 'package:pgme/core/models/lecture_model.dart';

part 'progress_model.g.dart';

@JsonSerializable()
class ProgressModel {
  @JsonKey(name: 'progress_id')
  final String progressId;

  final LectureModel lecture;

  @JsonKey(name: 'watch_time_seconds')
  final int watchTimeSeconds;

  @JsonKey(name: 'last_watched_position_seconds')
  final int lastWatchedPositionSeconds;

  @JsonKey(name: 'is_completed', defaultValue: false)
  final bool isCompleted;

  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;

  @JsonKey(name: 'last_watched_at')
  final String lastWatchedAt;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  ProgressModel({
    required this.progressId,
    required this.lecture,
    required this.watchTimeSeconds,
    required this.lastWatchedPositionSeconds,
    required this.isCompleted,
    required this.completionPercentage,
    required this.lastWatchedAt,
    this.createdAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressModelToJson(this);

  ProgressModel copyWith({
    String? progressId,
    LectureModel? lecture,
    int? watchTimeSeconds,
    int? lastWatchedPositionSeconds,
    bool? isCompleted,
    int? completionPercentage,
    String? lastWatchedAt,
    String? createdAt,
  }) {
    return ProgressModel(
      progressId: progressId ?? this.progressId,
      lecture: lecture ?? this.lecture,
      watchTimeSeconds: watchTimeSeconds ?? this.watchTimeSeconds,
      lastWatchedPositionSeconds:
          lastWatchedPositionSeconds ?? this.lastWatchedPositionSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Computed properties
  int get remainingSeconds =>
      (lecture.durationMinutes * 60) - lastWatchedPositionSeconds;

  int get remainingMinutes => (remainingSeconds / 60).ceil();

  String get formattedTimeRemaining {
    if (remainingMinutes < 60) {
      return '$remainingMinutes min left';
    }
    final hours = remainingMinutes ~/ 60;
    final mins = remainingMinutes % 60;
    return '$hours hr ${mins > 0 ? "$mins min" : ""} left';
  }
}
