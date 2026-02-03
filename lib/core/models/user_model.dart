import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'user_id')
  final String userId;

  final String? name;

  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  final String? email;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'is_new_user', defaultValue: false)
  final bool isNewUser;

  @JsonKey(name: 'onboarding_completed', defaultValue: false)
  final bool onboardingCompleted;

  @JsonKey(name: 'profile_completion_percentage', defaultValue: 0)
  final int profileCompletionPercentage;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  final String? gender;

  final String? address;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserModel({
    required this.userId,
    this.name,
    required this.phoneNumber,
    this.email,
    this.photoUrl,
    required this.isNewUser,
    required this.onboardingCompleted,
    required this.profileCompletionPercentage,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? userId,
    String? name,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    bool? isNewUser,
    bool? onboardingCompleted,
    int? profileCompletionPercentage,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isNewUser: isNewUser ?? this.isNewUser,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profileCompletionPercentage:
          profileCompletionPercentage ?? this.profileCompletionPercentage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
