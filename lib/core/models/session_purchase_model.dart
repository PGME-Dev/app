import 'package:json_annotation/json_annotation.dart';

part 'session_purchase_model.g.dart';

@JsonSerializable()
class SessionPurchaseModel {
  @JsonKey(name: 'purchase_id')
  final String purchaseId;

  @JsonKey(name: 'session_id')
  final String sessionId;

  @JsonKey(name: 'session_title')
  final String sessionTitle;

  @JsonKey(name: 'session_thumbnail')
  final String? sessionThumbnail;

  @JsonKey(name: 'session_status')
  final String sessionStatus;

  @JsonKey(name: 'scheduled_start_time')
  final String scheduledStartTime;

  @JsonKey(name: 'faculty_name')
  final String? facultyName;

  @JsonKey(name: 'faculty_photo')
  final String? facultyPhoto;

  @JsonKey(name: 'amount_paid')
  final num amountPaid;

  final String currency;

  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  @JsonKey(name: 'purchased_at')
  final String? purchasedAt;

  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  SessionPurchaseModel({
    required this.purchaseId,
    required this.sessionId,
    required this.sessionTitle,
    this.sessionThumbnail,
    required this.sessionStatus,
    required this.scheduledStartTime,
    this.facultyName,
    this.facultyPhoto,
    required this.amountPaid,
    required this.currency,
    required this.paymentStatus,
    this.purchasedAt,
    required this.isActive,
  });

  factory SessionPurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$SessionPurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionPurchaseModelToJson(this);

  SessionPurchaseModel copyWith({
    String? purchaseId,
    String? sessionId,
    String? sessionTitle,
    String? sessionThumbnail,
    String? sessionStatus,
    String? scheduledStartTime,
    String? facultyName,
    String? facultyPhoto,
    num? amountPaid,
    String? currency,
    String? paymentStatus,
    String? purchasedAt,
    bool? isActive,
  }) {
    return SessionPurchaseModel(
      purchaseId: purchaseId ?? this.purchaseId,
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      sessionThumbnail: sessionThumbnail ?? this.sessionThumbnail,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      facultyName: facultyName ?? this.facultyName,
      facultyPhoto: facultyPhoto ?? this.facultyPhoto,
      amountPaid: amountPaid ?? this.amountPaid,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Model for session access status response
@JsonSerializable()
class SessionAccessStatus {
  @JsonKey(name: 'has_access')
  final bool hasAccess;

  @JsonKey(name: 'is_free')
  final bool isFree;

  final num price;

  @JsonKey(name: 'compare_at_price')
  final num? compareAtPrice;

  @JsonKey(name: 'purchase_id')
  final String? purchaseId;

  @JsonKey(name: 'purchased_at')
  final String? purchasedAt;

  SessionAccessStatus({
    required this.hasAccess,
    required this.isFree,
    required this.price,
    this.compareAtPrice,
    this.purchaseId,
    this.purchasedAt,
  });

  factory SessionAccessStatus.fromJson(Map<String, dynamic> json) =>
      _$SessionAccessStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SessionAccessStatusToJson(this);
}

/// Model for Razorpay order response
@JsonSerializable()
class SessionOrderResponse {
  @JsonKey(name: 'order_id')
  final String orderId;

  final num amount;

  final String currency;

  final SessionOrderDetails session;

  SessionOrderResponse({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.session,
  });

  factory SessionOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionOrderResponseToJson(this);
}

@JsonSerializable()
class SessionOrderDetails {
  @JsonKey(name: 'session_id')
  final String sessionId;

  final String title;

  @JsonKey(name: 'scheduled_start_time')
  final String scheduledStartTime;

  SessionOrderDetails({
    required this.sessionId,
    required this.title,
    required this.scheduledStartTime,
  });

  factory SessionOrderDetails.fromJson(Map<String, dynamic> json) =>
      _$SessionOrderDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$SessionOrderDetailsToJson(this);
}
