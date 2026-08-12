// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workshop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkshopDayModel _$WorkshopDayModelFromJson(Map<String, dynamic> json) =>
    WorkshopDayModel(
      sessionId: json['session_id'] as String,
      dayNumber: (json['day_number'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledStartTime: json['scheduled_start_time'] as String,
      scheduledEndTime: json['scheduled_end_time'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      status: json['status'] as String,
      facultyName: json['faculty_name'] as String?,
      facultyPhotoUrl: json['faculty_photo_url'] as String?,
      joinOpensAt: json['join_opens_at'] as String?,
      canJoin: json['can_join'] as bool? ?? false,
      attended: json['attended'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkshopDayModelToJson(WorkshopDayModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'day_number': instance.dayNumber,
      'title': instance.title,
      'description': instance.description,
      'scheduled_start_time': instance.scheduledStartTime,
      'scheduled_end_time': instance.scheduledEndTime,
      'duration_minutes': instance.durationMinutes,
      'status': instance.status,
      'faculty_name': instance.facultyName,
      'faculty_photo_url': instance.facultyPhotoUrl,
      'join_opens_at': instance.joinOpensAt,
      'can_join': instance.canJoin,
      'attended': instance.attended,
    };

WorkshopFacultyModel _$WorkshopFacultyModelFromJson(
        Map<String, dynamic> json) =>
    WorkshopFacultyModel(
      facultyId: json['faculty_id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      specialization: json['specialization'] as String?,
      bio: json['bio'] as String?,
      qualifications: json['qualifications'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkshopFacultyModelToJson(
        WorkshopFacultyModel instance) =>
    <String, dynamic>{
      'faculty_id': instance.facultyId,
      'name': instance.name,
      'photo_url': instance.photoUrl,
      'specialization': instance.specialization,
      'bio': instance.bio,
      'qualifications': instance.qualifications,
      'experience_years': instance.experienceYears,
    };

WorkshopCertificateModel _$WorkshopCertificateModelFromJson(
        Map<String, dynamic> json) =>
    WorkshopCertificateModel(
      certificateId: json['certificate_id'] as String?,
      certificateNumber: json['certificate_number'] as String,
      issuedAt: json['issued_at'] as String?,
      daysAttended: (json['days_attended'] as num?)?.toInt(),
      totalDays: (json['total_days'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkshopCertificateModelToJson(
        WorkshopCertificateModel instance) =>
    <String, dynamic>{
      'certificate_id': instance.certificateId,
      'certificate_number': instance.certificateNumber,
      'issued_at': instance.issuedAt,
      'days_attended': instance.daysAttended,
      'total_days': instance.totalDays,
    };

WorkshopModel _$WorkshopModelFromJson(Map<String, dynamic> json) =>
    WorkshopModel(
      workshopId: json['workshop_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      facultyNames: (json['faculty_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      facultyPhotoUrls: (json['faculty_photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      thumbnailUrl: json['thumbnail_url'] as String?,
      brochureUrl: json['brochure_url'] as String?,
      brochureFilename: json['brochure_filename'] as String?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      dayCount: (json['day_count'] as num).toInt(),
      totalDurationMinutes:
          (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      compareAtPrice: (json['compare_at_price'] as num?)?.toInt(),
      isFree: json['is_free'] as bool? ?? false,
      status: json['status'] as String,
      platform: json['platform'] as String?,
      enrollmentMode: json['enrollment_mode'] as String?,
      capacityMode: json['capacity_mode'] as String?,
      maxSeats: (json['max_seats'] as num?)?.toInt(),
      enrollmentCount: (json['enrollment_count'] as num?)?.toInt() ?? 0,
      registrationClosesAt: json['registration_closes_at'] as String?,
      allowWaitlist: json['allow_waitlist'] as bool? ?? false,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => WorkshopDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      faculty: (json['faculty'] as List<dynamic>?)
              ?.map((e) =>
                  WorkshopFacultyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      certificateEnabled: json['certificate_enabled'] as bool? ?? false,
      certificateMinDaysAttended:
          (json['certificate_min_days_attended'] as num?)?.toInt(),
      hasAccess: json['has_access'] as bool? ?? false,
      accessReason: json['access_reason'] as String?,
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      enrollmentStatus: json['enrollment_status'] as String?,
      enrollmentType: json['enrollment_type'] as String?,
      waitlistPosition: (json['waitlist_position'] as num?)?.toInt(),
      daysAttended: (json['days_attended'] as num?)?.toInt() ?? 0,
      attendedDayNumbers: (json['attended_day_numbers'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      certificate: json['certificate'] == null
          ? null
          : WorkshopCertificateModel.fromJson(
              json['certificate'] as Map<String, dynamic>),
      registrationOpen: json['registration_open'] as bool? ?? true,
    );

Map<String, dynamic> _$WorkshopModelToJson(WorkshopModel instance) =>
    <String, dynamic>{
      'workshop_id': instance.workshopId,
      'title': instance.title,
      'description': instance.description,
      'subject_id': instance.subjectId,
      'subject_name': instance.subjectName,
      'faculty_names': instance.facultyNames,
      'faculty_photo_urls': instance.facultyPhotoUrls,
      'thumbnail_url': instance.thumbnailUrl,
      'brochure_url': instance.brochureUrl,
      'brochure_filename': instance.brochureFilename,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'day_count': instance.dayCount,
      'total_duration_minutes': instance.totalDurationMinutes,
      'price': instance.price,
      'compare_at_price': instance.compareAtPrice,
      'is_free': instance.isFree,
      'status': instance.status,
      'platform': instance.platform,
      'enrollment_mode': instance.enrollmentMode,
      'capacity_mode': instance.capacityMode,
      'max_seats': instance.maxSeats,
      'enrollment_count': instance.enrollmentCount,
      'registration_closes_at': instance.registrationClosesAt,
      'allow_waitlist': instance.allowWaitlist,
      'days': instance.days,
      'faculty': instance.faculty,
      'certificate_enabled': instance.certificateEnabled,
      'certificate_min_days_attended': instance.certificateMinDaysAttended,
      'has_access': instance.hasAccess,
      'access_reason': instance.accessReason,
      'is_enrolled': instance.isEnrolled,
      'enrollment_status': instance.enrollmentStatus,
      'enrollment_type': instance.enrollmentType,
      'waitlist_position': instance.waitlistPosition,
      'days_attended': instance.daysAttended,
      'attended_day_numbers': instance.attendedDayNumbers,
      'certificate': instance.certificate,
      'registration_open': instance.registrationOpen,
    };

WorkshopCapacityModel _$WorkshopCapacityModelFromJson(
        Map<String, dynamic> json) =>
    WorkshopCapacityModel(
      effectiveCapacity: (json['effective_capacity'] as num?)?.toInt(),
      isUnlimited: json['is_unlimited'] as bool? ?? true,
      confirmedEnrollments:
          (json['confirmed_enrollments'] as num?)?.toInt() ?? 0,
      waitlisted: (json['waitlisted'] as num?)?.toInt() ?? 0,
      availableSeats: (json['available_seats'] as num?)?.toInt(),
      isFull: json['is_full'] as bool? ?? false,
      allowWaitlist: json['allow_waitlist'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkshopCapacityModelToJson(
        WorkshopCapacityModel instance) =>
    <String, dynamic>{
      'effective_capacity': instance.effectiveCapacity,
      'is_unlimited': instance.isUnlimited,
      'confirmed_enrollments': instance.confirmedEnrollments,
      'waitlisted': instance.waitlisted,
      'available_seats': instance.availableSeats,
      'is_full': instance.isFull,
      'allow_waitlist': instance.allowWaitlist,
    };

WorkshopCertificateStatusModel _$WorkshopCertificateStatusModelFromJson(
        Map<String, dynamic> json) =>
    WorkshopCertificateStatusModel(
      eligible: json['eligible'] as bool? ?? false,
      reason: json['reason'] as String?,
      daysAttended: (json['days_attended'] as num?)?.toInt() ?? 0,
      requiredDays: (json['required_days'] as num?)?.toInt() ?? 0,
      totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
      issued: json['issued'] as bool? ?? false,
      certificate: json['certificate'] == null
          ? null
          : WorkshopCertificateModel.fromJson(
              json['certificate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkshopCertificateStatusModelToJson(
        WorkshopCertificateStatusModel instance) =>
    <String, dynamic>{
      'eligible': instance.eligible,
      'reason': instance.reason,
      'days_attended': instance.daysAttended,
      'required_days': instance.requiredDays,
      'total_days': instance.totalDays,
      'issued': instance.issued,
      'certificate': instance.certificate,
    };

WorkshopRecordingModel _$WorkshopRecordingModelFromJson(
        Map<String, dynamic> json) =>
    WorkshopRecordingModel(
      recordingId: json['recording_id'] as String,
      sessionId: json['session_id'] as String,
      workshopDay: (json['workshop_day'] as num?)?.toInt(),
      dayTitle: json['day_title'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      processingStatus: json['processing_status'] as String?,
      isLocked: json['is_locked'] as bool? ?? true,
      videoUrl: json['video_url'] as String?,
    );

Map<String, dynamic> _$WorkshopRecordingModelToJson(
        WorkshopRecordingModel instance) =>
    <String, dynamic>{
      'recording_id': instance.recordingId,
      'session_id': instance.sessionId,
      'workshop_day': instance.workshopDay,
      'day_title': instance.dayTitle,
      'title': instance.title,
      'description': instance.description,
      'duration_seconds': instance.durationSeconds,
      'thumbnail_url': instance.thumbnailUrl,
      'processing_status': instance.processingStatus,
      'is_locked': instance.isLocked,
      'video_url': instance.videoUrl,
    };
