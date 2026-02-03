import 'package:json_annotation/json_annotation.dart';

part 'subject_selection_model.g.dart';

@JsonSerializable()
class SubjectSelectionModel {
  @JsonKey(name: 'selection_id')
  final String selectionId;

  @JsonKey(name: 'subject_id')
  final String subjectId;

  @JsonKey(name: 'subject_name')
  final String subjectName;

  @JsonKey(name: 'subject_description')
  final String? subjectDescription;

  @JsonKey(name: 'subject_icon_url')
  final String? subjectIconUrl;

  @JsonKey(name: 'is_primary', defaultValue: false)
  final bool isPrimary;

  @JsonKey(name: 'selected_at')
  final String selectedAt;

  SubjectSelectionModel({
    required this.selectionId,
    required this.subjectId,
    required this.subjectName,
    this.subjectDescription,
    this.subjectIconUrl,
    required this.isPrimary,
    required this.selectedAt,
  });

  factory SubjectSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectSelectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectSelectionModelToJson(this);

  SubjectSelectionModel copyWith({
    String? selectionId,
    String? subjectId,
    String? subjectName,
    String? subjectDescription,
    String? subjectIconUrl,
    bool? isPrimary,
    String? selectedAt,
  }) {
    return SubjectSelectionModel(
      selectionId: selectionId ?? this.selectionId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectDescription: subjectDescription ?? this.subjectDescription,
      subjectIconUrl: subjectIconUrl ?? this.subjectIconUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }
}
