import 'package:json_annotation/json_annotation.dart';

part 'lecture_model.g.dart';

@JsonSerializable()
class LectureModel {
  @JsonKey(name: 'lecture_id')
  final String lectureId;

  final String title;

  @JsonKey(name: 'video_url')
  final String? videoUrl;

  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  final String? description;

  @JsonKey(name: 'sequence_number', defaultValue: 0)
  final int sequenceNumber;

  @JsonKey(name: 'is_free', defaultValue: false)
  final bool isFree;

  LectureModel({
    required this.lectureId,
    required this.title,
    this.videoUrl,
    required this.durationMinutes,
    this.thumbnailUrl,
    this.description,
    required this.sequenceNumber,
    required this.isFree,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) =>
      _$LectureModelFromJson(json);

  Map<String, dynamic> toJson() => _$LectureModelToJson(this);

  LectureModel copyWith({
    String? lectureId,
    String? title,
    String? videoUrl,
    int? durationMinutes,
    String? thumbnailUrl,
    String? description,
    int? sequenceNumber,
    bool? isFree,
  }) {
    return LectureModel(
      lectureId: lectureId ?? this.lectureId,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      isFree: isFree ?? this.isFree,
    );
  }

  // Computed property for duration in seconds
  int get durationSeconds => durationMinutes * 60;
}
