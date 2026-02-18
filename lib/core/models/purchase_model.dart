import 'package:json_annotation/json_annotation.dart';
import 'package:pgme/core/models/package_model.dart';

part 'purchase_model.g.dart';

@JsonSerializable()
class PurchaseModel {
  @JsonKey(name: 'purchase_id')
  final String purchaseId;

  final PackageModel package;

  @JsonKey(name: 'amount_paid')
  final int amountPaid;

  final String currency;

  @JsonKey(name: 'payment_status')
  final String paymentStatus; // "pending", "completed", "failed", "refunded"

  @JsonKey(name: 'purchased_at')
  final String purchasedAt;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  @JsonKey(name: 'auto_renewal_enabled', defaultValue: false)
  final bool autoRenewalEnabled;

  @JsonKey(name: 'days_remaining')
  final int daysRemaining;

  @JsonKey(name: 'tier_index')
  final int? tierIndex;

  @JsonKey(name: 'tier_name')
  final String? tierName;

  @JsonKey(name: 'is_upgrade', defaultValue: false)
  final bool isUpgrade;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  PurchaseModel({
    required this.purchaseId,
    required this.package,
    required this.amountPaid,
    required this.currency,
    required this.paymentStatus,
    required this.purchasedAt,
    required this.expiresAt,
    required this.isActive,
    required this.autoRenewalEnabled,
    required this.daysRemaining,
    this.tierIndex,
    this.tierName,
    required this.isUpgrade,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseModelToJson(this);

  PurchaseModel copyWith({
    String? purchaseId,
    PackageModel? package,
    int? amountPaid,
    String? currency,
    String? paymentStatus,
    String? purchasedAt,
    String? expiresAt,
    bool? isActive,
    bool? autoRenewalEnabled,
    int? daysRemaining,
    int? tierIndex,
    String? tierName,
    bool? isUpgrade,
    String? createdAt,
    String? updatedAt,
  }) {
    return PurchaseModel(
      purchaseId: purchaseId ?? this.purchaseId,
      package: package ?? this.package,
      amountPaid: amountPaid ?? this.amountPaid,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      autoRenewalEnabled: autoRenewalEnabled ?? this.autoRenewalEnabled,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      tierIndex: tierIndex ?? this.tierIndex,
      tierName: tierName ?? this.tierName,
      isUpgrade: isUpgrade ?? this.isUpgrade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
