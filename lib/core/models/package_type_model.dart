import 'package:json_annotation/json_annotation.dart';

part 'package_type_model.g.dart';

@JsonSerializable()
class PackageTypeModel {
  @JsonKey(name: 'type_id')
  final String typeId;

  final String name;

  final String description;

  @JsonKey(name: 'trailer_video_url')
  final String? trailerVideoUrl;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  PackageTypeModel({
    required this.typeId,
    required this.name,
    required this.description,
    this.trailerVideoUrl,
    this.thumbnailUrl,
  });

  factory PackageTypeModel.fromJson(Map<String, dynamic> json) =>
      _$PackageTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageTypeModelToJson(this);
}
