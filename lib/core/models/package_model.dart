import 'package:json_annotation/json_annotation.dart';
import 'package:pgme/core/utils/package_type_slug.dart';

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
class PackageTier {
  final int index;
  final String name;
  @JsonKey(name: 'duration_days')
  final int durationDays;
  final int price;
  @JsonKey(name: 'original_price')
  final int? originalPrice;
  @JsonKey(name: 'effective_price')
  final int effectivePrice;
  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  PackageTier({
    required this.index,
    required this.name,
    required this.durationDays,
    required this.price,
    this.originalPrice,
    required this.effectivePrice,
    required this.displayOrder,
  });

  factory PackageTier.fromJson(Map<String, dynamic> json) =>
      _$PackageTierFromJson(json);
  Map<String, dynamic> toJson() => _$PackageTierToJson(this);
}

@JsonSerializable()
class CurrentTierInfo {
  @JsonKey(name: 'tier_index')
  final int? tierIndex;
  @JsonKey(name: 'tier_name')
  final String? tierName;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  @JsonKey(name: 'days_remaining')
  final int? daysRemaining;
  @JsonKey(name: 'purchase_id')
  final String? purchaseId;

  CurrentTierInfo({
    this.tierIndex,
    this.tierName,
    this.expiresAt,
    this.daysRemaining,
    this.purchaseId,
  });

  factory CurrentTierInfo.fromJson(Map<String, dynamic> json) =>
      _$CurrentTierInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentTierInfoToJson(this);
}

@JsonSerializable()
class PackageModel {
  @JsonKey(name: 'package_id')
  final String packageId;

  final String name;

  /// Display name of the package type, e.g. "Theory", "Practical", "Combos".
  ///
  /// This is free text an admin can rename at any time — never compare against
  /// it. Use [typeSlug] (or `PackageTypeSlug.matches`) instead.
  @JsonKey(name: 'package_type')
  final String? type;

  /// Stable identifier for the package type: 'theory', 'practical', 'combo'.
  ///
  /// Server-derived, so renaming the type in the admin panel can't change it.
  /// Falls back to a locally derived slug when an older backend omits it.
  @JsonKey(name: 'package_type_slug')
  final String? packageTypeSlug;

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

  @JsonKey(name: 'sale_discount_percent')
  final int? saleDiscountPercent;

  @JsonKey(name: 'duration_days')
  final int? durationDays;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'video_lectures_thumbnail_url')
  final String? videoLecturesThumbnailUrl;

  @JsonKey(name: 'notes_thumbnail_url')
  final String? notesThumbnailUrl;

  @JsonKey(name: 'trailer_video_url')
  final String? trailerVideoUrl;

  @JsonKey(fromJson: _featuresFromJson)
  final List<String>? features;

  @JsonKey(name: 'rich_description')
  final String? richDescription;

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  @JsonKey(name: 'is_purchased', defaultValue: false)
  final bool isPurchased;

  @JsonKey(name: 'access_revoked', defaultValue: false)
  final bool accessRevoked;

  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  // Tier fields
  @JsonKey(name: 'has_tiers', defaultValue: false)
  final bool hasTiers;

  final List<PackageTier>? tiers;

  @JsonKey(name: 'starting_price')
  final int? startingPrice;

  @JsonKey(name: 'current_tier_index')
  final int? currentTierIndex;

  @JsonKey(name: 'current_tier_name')
  final String? currentTierName;

  @JsonKey(name: 'current_tier')
  final CurrentTierInfo? currentTier;

  PackageModel({
    required this.packageId,
    required this.name,
    this.type,
    this.packageTypeSlug,
    this.description,
    required this.price,
    this.originalPrice,
    required this.isOnSale,
    this.salePrice,
    this.saleEndDate,
    this.saleDiscountPercent,
    this.durationDays,
    this.thumbnailUrl,
    this.videoLecturesThumbnailUrl,
    this.notesThumbnailUrl,
    this.trailerVideoUrl,
    this.features,
    this.richDescription,
    required this.displayOrder,
    required this.isPurchased,
    required this.accessRevoked,
    this.expiresAt,
    required this.hasTiers,
    this.tiers,
    this.startingPrice,
    this.currentTierIndex,
    this.currentTierName,
    this.currentTier,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageModelToJson(this);

  /// Stable package-type slug, falling back to one derived from the display
  /// name when the backend predates `package_type_slug`.
  String? get typeSlug =>
      PackageTypeSlug.resolve(slug: packageTypeSlug, name: type);

  bool get isTheory => typeSlug == PackageTypeSlug.theory;
  bool get isPractical => typeSlug == PackageTypeSlug.practical;
  bool get isCombo => typeSlug == PackageTypeSlug.combo;

  /// Whether this package has rich HTML content
  bool get hasRichDescription =>
      richDescription != null && richDescription!.isNotEmpty;

  /// Get the display price (first tier effective price or sale price or regular price)
  int get displayPrice {
    if (hasTiers && tiers != null && tiers!.isNotEmpty) {
      return tiers!.first.effectivePrice;
    }
    if (isOnSale && salePrice != null) return salePrice!;
    return price;
  }

  PackageModel copyWith({
    String? packageId,
    String? name,
    String? type,
    String? packageTypeSlug,
    String? description,
    int? price,
    int? originalPrice,
    bool? isOnSale,
    int? salePrice,
    String? saleEndDate,
    int? saleDiscountPercent,
    int? durationDays,
    String? thumbnailUrl,
    String? videoLecturesThumbnailUrl,
    String? notesThumbnailUrl,
    String? trailerVideoUrl,
    List<String>? features,
    String? richDescription,
    int? displayOrder,
    bool? isPurchased,
    bool? accessRevoked,
    String? expiresAt,
    bool? hasTiers,
    List<PackageTier>? tiers,
    int? startingPrice,
    int? currentTierIndex,
    String? currentTierName,
    CurrentTierInfo? currentTier,
  }) {
    return PackageModel(
      packageId: packageId ?? this.packageId,
      name: name ?? this.name,
      type: type ?? this.type,
      packageTypeSlug: packageTypeSlug ?? this.packageTypeSlug,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isOnSale: isOnSale ?? this.isOnSale,
      salePrice: salePrice ?? this.salePrice,
      saleEndDate: saleEndDate ?? this.saleEndDate,
      saleDiscountPercent: saleDiscountPercent ?? this.saleDiscountPercent,
      durationDays: durationDays ?? this.durationDays,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoLecturesThumbnailUrl: videoLecturesThumbnailUrl ?? this.videoLecturesThumbnailUrl,
      notesThumbnailUrl: notesThumbnailUrl ?? this.notesThumbnailUrl,
      trailerVideoUrl: trailerVideoUrl ?? this.trailerVideoUrl,
      features: features ?? this.features,
      richDescription: richDescription ?? this.richDescription,
      displayOrder: displayOrder ?? this.displayOrder,
      isPurchased: isPurchased ?? this.isPurchased,
      accessRevoked: accessRevoked ?? this.accessRevoked,
      expiresAt: expiresAt ?? this.expiresAt,
      hasTiers: hasTiers ?? this.hasTiers,
      tiers: tiers ?? this.tiers,
      startingPrice: startingPrice ?? this.startingPrice,
      currentTierIndex: currentTierIndex ?? this.currentTierIndex,
      currentTierName: currentTierName ?? this.currentTierName,
      currentTier: currentTier ?? this.currentTier,
    );
  }
}
