import 'package:json_annotation/json_annotation.dart';

part 'package_model.g.dart';

/// Converts features from API (can be String or List) to List<String>
List<String>? _featuresFromJson(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String) {
    if (value.isEmpty) return null;
    // Split by newline or comma, filter empty strings
    return value
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return null;
}

@JsonSerializable()
class PackageModel {
  @JsonKey(name: 'package_id')
  final String packageId;

  final String name;

  @JsonKey(name: 'package_type')
  final String? type; // "Theory", "Practical"

  final String? description;

  final int price;

  @JsonKey(name: 'original_price')
  final int? originalPrice;

  @JsonKey(name: 'is_on_sale', defaultValue: false)
  final bool isOnSale;

  @JsonKey(name: 'sale_price')
  final int? salePrice;

  @JsonKey(name: 'sale_end_date')
  final String? saleEndDate;

  @JsonKey(name: 'duration_days')
  final int? durationDays;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(fromJson: _featuresFromJson)
  final List<String>? features;

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  @JsonKey(name: 'is_purchased', defaultValue: false)
  final bool isPurchased;

  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  PackageModel({
    required this.packageId,
    required this.name,
    this.type,
    this.description,
    required this.price,
    this.originalPrice,
    required this.isOnSale,
    this.salePrice,
    this.saleEndDate,
    this.durationDays,
    this.thumbnailUrl,
    this.features,
    required this.displayOrder,
    required this.isPurchased,
    this.expiresAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageModelToJson(this);

  PackageModel copyWith({
    String? packageId,
    String? name,
    String? type,
    String? description,
    int? price,
    int? originalPrice,
    bool? isOnSale,
    int? salePrice,
    String? saleEndDate,
    int? durationDays,
    String? thumbnailUrl,
    List<String>? features,
    int? displayOrder,
    bool? isPurchased,
    String? expiresAt,
  }) {
    return PackageModel(
      packageId: packageId ?? this.packageId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isOnSale: isOnSale ?? this.isOnSale,
      salePrice: salePrice ?? this.salePrice,
      saleEndDate: saleEndDate ?? this.saleEndDate,
      durationDays: durationDays ?? this.durationDays,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      features: features ?? this.features,
      displayOrder: displayOrder ?? this.displayOrder,
      isPurchased: isPurchased ?? this.isPurchased,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
