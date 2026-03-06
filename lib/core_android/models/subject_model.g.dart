// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectModel _$SubjectModelFromJson(Map<String, dynamic> json) => SubjectModel(
      id: json['_id'] as String,
      subjectId: json['subject_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      whatsappCommunityLink: json['whatsapp_community_link'] as String?,
      displayOrder: (json['display_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$SubjectModelToJson(SubjectModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'subject_id': instance.subjectId,
      'name': instance.name,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'display_order': instance.displayOrder,
      'whatsapp_community_link': instance.whatsappCommunityLink,
      'is_active': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
