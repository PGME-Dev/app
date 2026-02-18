// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseModel _$PurchaseModelFromJson(Map<String, dynamic> json) =>
    PurchaseModel(
      purchaseId: json['purchase_id'] as String,
      package: PackageModel.fromJson(json['package'] as Map<String, dynamic>),
      amountPaid: (json['amount_paid'] as num).toInt(),
      currency: json['currency'] as String,
      paymentStatus: json['payment_status'] as String,
      purchasedAt: json['purchased_at'] as String,
      expiresAt: json['expires_at'] as String,
      isActive: json['is_active'] as bool? ?? true,
      autoRenewalEnabled: json['auto_renewal_enabled'] as bool? ?? false,
      daysRemaining: (json['days_remaining'] as num).toInt(),
      tierIndex: (json['tier_index'] as num?)?.toInt(),
      tierName: json['tier_name'] as String?,
      isUpgrade: json['is_upgrade'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$PurchaseModelToJson(PurchaseModel instance) =>
    <String, dynamic>{
      'purchase_id': instance.purchaseId,
      'package': instance.package,
      'amount_paid': instance.amountPaid,
      'currency': instance.currency,
      'payment_status': instance.paymentStatus,
      'purchased_at': instance.purchasedAt,
      'expires_at': instance.expiresAt,
      'is_active': instance.isActive,
      'auto_renewal_enabled': instance.autoRenewalEnabled,
      'days_remaining': instance.daysRemaining,
      'tier_index': instance.tierIndex,
      'tier_name': instance.tierName,
      'is_upgrade': instance.isUpgrade,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
