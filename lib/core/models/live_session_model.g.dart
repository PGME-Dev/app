// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveSessionModel _$LiveSessionModelFromJson(Map<String, dynamic> json) =>
    LiveSessionModel(
      sessionId: json['session_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      facultyId: json['faculty_id'] as String?,
      facultyName: json['faculty_name'] as String?,
      facultyPhotoUrl: json['faculty_photo_url'] as String?,
      facultySpecialization: json['faculty_specialization'] as String?,
      scheduledStartTime: json['scheduled_start_time'] as String,
      scheduledEndTime: json['scheduled_end_time'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      meetingLink: json['meeting_link'] as String?,
      platform: json['platform'] as String,
      status: json['status'] as String,
      maxAttendees: (json['max_attendees'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$LiveSessionModelToJson(LiveSessionModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'title': instance.title,
      'description': instance.description,
      'subject_id': instance.subjectId,
      'subject_name': instance.subjectName,
      'faculty_id': instance.facultyId,
      'faculty_name': instance.facultyName,
      'faculty_photo_url': instance.facultyPhotoUrl,
      'faculty_specialization': instance.facultySpecialization,
      'scheduled_start_time': instance.scheduledStartTime,
      'scheduled_end_time': instance.scheduledEndTime,
      'duration_minutes': instance.durationMinutes,
      'meeting_link': instance.meetingLink,
      'platform': instance.platform,
      'status': instance.status,
      'max_attendees': instance.maxAttendees,
      'thumbnail_url': instance.thumbnailUrl,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
