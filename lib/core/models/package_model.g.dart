// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
      packageId: json['package_id'] as String,
      name: json['name'] as String,
      type: json['package_type'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      originalPrice: (json['original_price'] as num?)?.toInt(),
      isOnSale: json['is_on_sale'] as bool? ?? false,
      salePrice: (json['sale_price'] as num?)?.toInt(),
      saleEndDate: json['sale_end_date'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      'package_id': instance.packageId,
      'name': instance.name,
      'package_type': instance.type,
      'description': instance.description,
      'price': instance.price,
      'original_price': instance.originalPrice,
      'is_on_sale': instance.isOnSale,
      'sale_price': instance.salePrice,
      'sale_end_date': instance.saleEndDate,
      'duration_days': instance.durationDays,
      'thumbnail_url': instance.thumbnailUrl,
      'features': instance.features,
      'display_order': instance.displayOrder,
    };
