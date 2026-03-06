import 'package:json_annotation/json_annotation.dart';

part 'subject_model.g.dart';

@JsonSerializable()
class SubjectModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'subject_id')
  final String subjectId;

  final String name;
  final String description;

  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'whatsapp_community_link')
  final String? whatsappCommunityLink;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  SubjectModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.description,
    this.iconUrl,
    this.whatsappCommunityLink,
    required this.displayOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectModelToJson(this);
}
