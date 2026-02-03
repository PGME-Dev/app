// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_selection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectSelectionModel _$SubjectSelectionModelFromJson(
        Map<String, dynamic> json) =>
    SubjectSelectionModel(
      selectionId: json['selection_id'] as String,
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      subjectDescription: json['subject_description'] as String?,
      subjectIconUrl: json['subject_icon_url'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      selectedAt: json['selected_at'] as String,
    );

Map<String, dynamic> _$SubjectSelectionModelToJson(
        SubjectSelectionModel instance) =>
    <String, dynamic>{
      'selection_id': instance.selectionId,
      'subject_id': instance.subjectId,
      'subject_name': instance.subjectName,
      'subject_description': instance.subjectDescription,
      'subject_icon_url': instance.subjectIconUrl,
      'is_primary': instance.isPrimary,
      'selected_at': instance.selectedAt,
    };
