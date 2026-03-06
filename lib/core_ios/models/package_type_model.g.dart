// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageTypeModel _$PackageTypeModelFromJson(Map<String, dynamic> json) =>
    PackageTypeModel(
      typeId: json['type_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      trailerVideoUrl: json['trailer_video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$PackageTypeModelToJson(PackageTypeModel instance) =>
    <String, dynamic>{
      'type_id': instance.typeId,
      'name': instance.name,
      'description': instance.description,
      'trailer_video_url': instance.trailerVideoUrl,
      'thumbnail_url': instance.thumbnailUrl,
    };
