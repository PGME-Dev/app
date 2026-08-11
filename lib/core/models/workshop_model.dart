import 'package:json_annotation/json_annotation.dart';

part 'workshop_model.g.dart';

/// One day of a workshop.
///
/// Backed by a LiveSession server-side, so [sessionId] is what the join and
/// Zoom-signature endpoints take — the same ones a standalone live session uses.
@JsonSerializable()
class WorkshopDayModel {
  @JsonKey(name: 'session_id')
  final String sessionId;

  @JsonKey(name: 'day_number')
  final int dayNumber;

  final String title;

  final String? description;

  @JsonKey(name: 'scheduled_start_time')
  final String scheduledStartTime;

  @JsonKey(name: 'scheduled_end_time')
  final String scheduledEndTime;

  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  /// 'scheduled' | 'live' | 'completed' | 'cancelled'
  final String status;

  @JsonKey(name: 'faculty_name')
  final String? facultyName;

  @JsonKey(name: 'faculty_photo_url')
  final String? facultyPhotoUrl;

  /// When the join window opens — 10 minutes before the day starts.
  @JsonKey(name: 'join_opens_at')
  final String? joinOpensAt;

  /// Server's verdict: entitled AND inside the join window AND not ended.
  @JsonKey(name: 'can_join', defaultValue: false)
  final bool canJoin;

  @JsonKey(defaultValue: false)
  final bool attended;

  WorkshopDayModel({
    required this.sessionId,
    required this.dayNumber,
    required this.title,
    this.description,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.durationMinutes,
    required this.status,
    this.facultyName,
    this.facultyPhotoUrl,
    this.joinOpensAt,
    this.canJoin = false,
    this.attended = false,
  });

  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isLive => status == 'live';

  factory WorkshopDayModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopDayModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopDayModelToJson(this);
}

/// Faculty teaching on a workshop (detail payload only).
@JsonSerializable()
class WorkshopFacultyModel {
  @JsonKey(name: 'faculty_id')
  final String facultyId;
  final String name;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  final String? specialization;
  final String? bio;
  final String? qualifications;
  @JsonKey(name: 'experience_years')
  final int? experienceYears;

  WorkshopFacultyModel({
    required this.facultyId,
    required this.name,
    this.photoUrl,
    this.specialization,
    this.bio,
    this.qualifications,
    this.experienceYears,
  });

  factory WorkshopFacultyModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopFacultyModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopFacultyModelToJson(this);
}

/// A certificate the signed-in user already holds for this workshop.
@JsonSerializable()
class WorkshopCertificateModel {
  @JsonKey(name: 'certificate_id')
  final String? certificateId;
  @JsonKey(name: 'certificate_number')
  final String certificateNumber;
  @JsonKey(name: 'issued_at')
  final String? issuedAt;
  @JsonKey(name: 'days_attended')
  final int? daysAttended;
  @JsonKey(name: 'total_days')
  final int? totalDays;

  WorkshopCertificateModel({
    this.certificateId,
    required this.certificateNumber,
    this.issuedAt,
    this.daysAttended,
    this.totalDays,
  });

  factory WorkshopCertificateModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopCertificateModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopCertificateModelToJson(this);
}

/// A multi-day workshop.
///
/// The list endpoint returns the headline fields; the detail endpoint adds
/// [days], [faculty] and — when the caller is authenticated — their access and
/// attendance state.
@JsonSerializable()
class WorkshopModel {
  @JsonKey(name: 'workshop_id')
  final String workshopId;

  final String title;

  final String? description;

  @JsonKey(name: 'subject_id')
  final String? subjectId;

  @JsonKey(name: 'subject_name')
  final String? subjectName;

  @JsonKey(name: 'faculty_names', defaultValue: [])
  final List<String> facultyNames;

  @JsonKey(name: 'faculty_photo_urls', defaultValue: [])
  final List<String> facultyPhotoUrls;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'start_date')
  final String startDate;

  @JsonKey(name: 'end_date')
  final String endDate;

  @JsonKey(name: 'day_count')
  final int dayCount;

  @JsonKey(name: 'total_duration_minutes', defaultValue: 0)
  final int totalDurationMinutes;

  final int price;

  @JsonKey(name: 'compare_at_price')
  final int? compareAtPrice;

  @JsonKey(name: 'is_free', defaultValue: false)
  final bool isFree;

  /// 'scheduled' | 'live' | 'completed' | 'cancelled'
  final String status;

  final String? platform;

  @JsonKey(name: 'enrollment_mode')
  final String? enrollmentMode;

  @JsonKey(name: 'capacity_mode')
  final String? capacityMode;

  @JsonKey(name: 'max_seats')
  final int? maxSeats;

  @JsonKey(name: 'enrollment_count', defaultValue: 0)
  final int enrollmentCount;

  @JsonKey(name: 'registration_closes_at')
  final String? registrationClosesAt;

  @JsonKey(name: 'allow_waitlist', defaultValue: false)
  final bool allowWaitlist;

  // --- Detail-only ---
  @JsonKey(defaultValue: [])
  final List<WorkshopDayModel> days;

  @JsonKey(defaultValue: [])
  final List<WorkshopFacultyModel> faculty;

  @JsonKey(name: 'certificate_enabled', defaultValue: false)
  final bool certificateEnabled;

  @JsonKey(name: 'certificate_min_days_attended')
  final int? certificateMinDaysAttended;

  // --- Caller state (detail endpoint, authenticated) ---
  @JsonKey(name: 'has_access', defaultValue: false)
  final bool hasAccess;

  /// Why access was denied: 'payment_required', 'enrollment_required',
  /// 'waitlisted', 'enrollment_cancelled', 'enrollment_disabled', null.
  @JsonKey(name: 'access_reason')
  final String? accessReason;

  @JsonKey(name: 'is_enrolled', defaultValue: false)
  final bool isEnrolled;

  @JsonKey(name: 'enrollment_status')
  final String? enrollmentStatus;

  @JsonKey(name: 'enrollment_type')
  final String? enrollmentType;

  @JsonKey(name: 'waitlist_position')
  final int? waitlistPosition;

  @JsonKey(name: 'days_attended', defaultValue: 0)
  final int daysAttended;

  @JsonKey(name: 'attended_day_numbers', defaultValue: [])
  final List<int> attendedDayNumbers;

  final WorkshopCertificateModel? certificate;

  @JsonKey(name: 'registration_open', defaultValue: true)
  final bool registrationOpen;

  WorkshopModel({
    required this.workshopId,
    required this.title,
    this.description,
    this.subjectId,
    this.subjectName,
    this.facultyNames = const [],
    this.facultyPhotoUrls = const [],
    this.thumbnailUrl,
    required this.startDate,
    required this.endDate,
    required this.dayCount,
    this.totalDurationMinutes = 0,
    this.price = 0,
    this.compareAtPrice,
    this.isFree = false,
    required this.status,
    this.platform,
    this.enrollmentMode,
    this.capacityMode,
    this.maxSeats,
    this.enrollmentCount = 0,
    this.registrationClosesAt,
    this.allowWaitlist = false,
    this.days = const [],
    this.faculty = const [],
    this.certificateEnabled = false,
    this.certificateMinDaysAttended,
    this.hasAccess = false,
    this.accessReason,
    this.isEnrolled = false,
    this.enrollmentStatus,
    this.enrollmentType,
    this.waitlistPosition,
    this.daysAttended = 0,
    this.attendedDayNumbers = const [],
    this.certificate,
    this.registrationOpen = true,
  });

  /// Paid only when explicitly not free AND priced — mirrors the server's rule,
  /// so a misconfigured (is_free=false, price=0) workshop reads as free rather
  /// than an unpayable wall.
  bool get isPaid => !isFree && price > 0;

  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isLive => status == 'live';

  /// Days that count toward completion — cancelled ones never do.
  List<WorkshopDayModel> get activeDays =>
      days.where((d) => !d.isCancelled).toList();

  bool get isWaitlisted => enrollmentStatus == 'waitlisted';

  factory WorkshopModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopModelToJson(this);
}

/// Seat availability, from the public capacity endpoint.
@JsonSerializable()
class WorkshopCapacityModel {
  @JsonKey(name: 'effective_capacity')
  final int? effectiveCapacity;
  @JsonKey(name: 'is_unlimited', defaultValue: true)
  final bool isUnlimited;
  @JsonKey(name: 'confirmed_enrollments', defaultValue: 0)
  final int confirmedEnrollments;
  @JsonKey(defaultValue: 0)
  final int waitlisted;
  @JsonKey(name: 'available_seats')
  final int? availableSeats;
  @JsonKey(name: 'is_full', defaultValue: false)
  final bool isFull;
  @JsonKey(name: 'allow_waitlist', defaultValue: false)
  final bool allowWaitlist;

  WorkshopCapacityModel({
    this.effectiveCapacity,
    this.isUnlimited = true,
    this.confirmedEnrollments = 0,
    this.waitlisted = 0,
    this.availableSeats,
    this.isFull = false,
    this.allowWaitlist = false,
  });

  factory WorkshopCapacityModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopCapacityModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopCapacityModelToJson(this);
}

/// Certificate eligibility for the signed-in user.
@JsonSerializable()
class WorkshopCertificateStatusModel {
  @JsonKey(defaultValue: false)
  final bool eligible;

  /// 'certificates_not_enabled' | 'workshop_not_completed' | 'not_enrolled' |
  /// 'insufficient_attendance' | null
  final String? reason;

  @JsonKey(name: 'days_attended', defaultValue: 0)
  final int daysAttended;

  @JsonKey(name: 'required_days', defaultValue: 0)
  final int requiredDays;

  @JsonKey(name: 'total_days', defaultValue: 0)
  final int totalDays;

  @JsonKey(defaultValue: false)
  final bool issued;

  final WorkshopCertificateModel? certificate;

  WorkshopCertificateStatusModel({
    this.eligible = false,
    this.reason,
    this.daysAttended = 0,
    this.requiredDays = 0,
    this.totalDays = 0,
    this.issued = false,
    this.certificate,
  });

  factory WorkshopCertificateStatusModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopCertificateStatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopCertificateStatusModelToJson(this);
}

/// A per-day recording.
@JsonSerializable()
class WorkshopRecordingModel {
  @JsonKey(name: 'recording_id')
  final String recordingId;
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'workshop_day')
  final int? workshopDay;
  @JsonKey(name: 'day_title')
  final String? dayTitle;
  final String title;
  final String? description;
  @JsonKey(name: 'duration_seconds', defaultValue: 0)
  final int durationSeconds;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'processing_status')
  final String? processingStatus;
  @JsonKey(name: 'is_locked', defaultValue: true)
  final bool isLocked;
  @JsonKey(name: 'video_url')
  final String? videoUrl;

  WorkshopRecordingModel({
    required this.recordingId,
    required this.sessionId,
    this.workshopDay,
    this.dayTitle,
    required this.title,
    this.description,
    this.durationSeconds = 0,
    this.thumbnailUrl,
    this.processingStatus,
    this.isLocked = true,
    this.videoUrl,
  });

  bool get isPlayable => !isLocked && videoUrl != null && videoUrl!.isNotEmpty;

  factory WorkshopRecordingModel.fromJson(Map<String, dynamic> json) =>
      _$WorkshopRecordingModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkshopRecordingModelToJson(this);
}
