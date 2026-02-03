import 'package:json_annotation/json_annotation.dart';

part 'live_session_model.g.dart';

@JsonSerializable()
class LiveSessionModel {
  @JsonKey(name: 'session_id')
  final String sessionId;

  final String title;

  final String? description;

  @JsonKey(name: 'subject_id')
  final String? subjectId;

  @JsonKey(name: 'subject_name')
  final String? subjectName;

  @JsonKey(name: 'faculty_id')
  final String? facultyId;

  @JsonKey(name: 'faculty_name')
  final String? facultyName;

  @JsonKey(name: 'faculty_photo_url')
  final String? facultyPhotoUrl;

  @JsonKey(name: 'faculty_specialization')
  final String? facultySpecialization;

  @JsonKey(name: 'scheduled_start_time')
  final String scheduledStartTime;

  @JsonKey(name: 'scheduled_end_time')
  final String scheduledEndTime;

  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  @JsonKey(name: 'meeting_link')
  final String? meetingLink;

  final String platform;

  final String status; // "scheduled", "live", "completed", "cancelled"

  @JsonKey(name: 'max_attendees')
  final int? maxAttendees;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  LiveSessionModel({
    required this.sessionId,
    required this.title,
    this.description,
    this.subjectId,
    this.subjectName,
    this.facultyId,
    this.facultyName,
    this.facultyPhotoUrl,
    this.facultySpecialization,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.durationMinutes,
    this.meetingLink,
    required this.platform,
    required this.status,
    this.maxAttendees,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory LiveSessionModel.fromJson(Map<String, dynamic> json) =>
      _$LiveSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveSessionModelToJson(this);

  LiveSessionModel copyWith({
    String? sessionId,
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    String? facultyId,
    String? facultyName,
    String? facultyPhotoUrl,
    String? facultySpecialization,
    String? scheduledStartTime,
    String? scheduledEndTime,
    int? durationMinutes,
    String? meetingLink,
    String? platform,
    String? status,
    int? maxAttendees,
    String? thumbnailUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return LiveSessionModel(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      facultyPhotoUrl: facultyPhotoUrl ?? this.facultyPhotoUrl,
      facultySpecialization: facultySpecialization ?? this.facultySpecialization,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      meetingLink: meetingLink ?? this.meetingLink,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
