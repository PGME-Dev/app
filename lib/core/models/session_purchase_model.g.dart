// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionPurchaseModel _$SessionPurchaseModelFromJson(
        Map<String, dynamic> json) =>
    SessionPurchaseModel(
      purchaseId: json['purchase_id'] as String,
      sessionId: json['session_id'] as String,
      sessionTitle: json['session_title'] as String,
      sessionThumbnail: json['session_thumbnail'] as String?,
      sessionStatus: json['session_status'] as String,
      scheduledStartTime: json['scheduled_start_time'] as String,
      facultyName: json['faculty_name'] as String?,
      facultyPhoto: json['faculty_photo'] as String?,
      amountPaid: json['amount_paid'] as num,
      currency: json['currency'] as String,
      paymentStatus: json['payment_status'] as String,
      purchasedAt: json['purchased_at'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$SessionPurchaseModelToJson(
        SessionPurchaseModel instance) =>
    <String, dynamic>{
      'purchase_id': instance.purchaseId,
      'session_id': instance.sessionId,
      'session_title': instance.sessionTitle,
      'session_thumbnail': instance.sessionThumbnail,
      'session_status': instance.sessionStatus,
      'scheduled_start_time': instance.scheduledStartTime,
      'faculty_name': instance.facultyName,
      'faculty_photo': instance.facultyPhoto,
      'amount_paid': instance.amountPaid,
      'currency': instance.currency,
      'payment_status': instance.paymentStatus,
      'purchased_at': instance.purchasedAt,
      'is_active': instance.isActive,
    };

SessionAccessStatus _$SessionAccessStatusFromJson(Map<String, dynamic> json) =>
    SessionAccessStatus(
      hasAccess: json['has_access'] as bool,
      isFree: json['is_free'] as bool,
      price: json['price'] as num,
      compareAtPrice: json['compare_at_price'] as num?,
      purchaseId: json['purchase_id'] as String?,
      purchasedAt: json['purchased_at'] as String?,
    );

Map<String, dynamic> _$SessionAccessStatusToJson(
        SessionAccessStatus instance) =>
    <String, dynamic>{
      'has_access': instance.hasAccess,
      'is_free': instance.isFree,
      'price': instance.price,
      'compare_at_price': instance.compareAtPrice,
      'purchase_id': instance.purchaseId,
      'purchased_at': instance.purchasedAt,
    };

SessionOrderResponse _$SessionOrderResponseFromJson(
        Map<String, dynamic> json) =>
    SessionOrderResponse(
      orderId: json['order_id'] as String,
      amount: json['amount'] as num,
      currency: json['currency'] as String,
      session:
          SessionOrderDetails.fromJson(json['session'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionOrderResponseToJson(
        SessionOrderResponse instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'session': instance.session,
    };

SessionOrderDetails _$SessionOrderDetailsFromJson(Map<String, dynamic> json) =>
    SessionOrderDetails(
      sessionId: json['session_id'] as String,
      title: json['title'] as String,
      scheduledStartTime: json['scheduled_start_time'] as String,
    );

Map<String, dynamic> _$SessionOrderDetailsToJson(
        SessionOrderDetails instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'title': instance.title,
      'scheduled_start_time': instance.scheduledStartTime,
    };
