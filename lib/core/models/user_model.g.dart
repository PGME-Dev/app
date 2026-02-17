// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      isNewUser: json['is_new_user'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      profileCompletionPercentage:
          (json['profile_completion_percentage'] as num?)?.toInt() ?? 0,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      studentId: json['student_id'] as String?,
      ugCollege: json['ug_college'] as String?,
      pgCollege: json['pg_college'] as String?,
      affiliatedOrganisation: json['affiliated_organisation'] as String?,
      currentDesignation: json['current_designation'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'photo_url': instance.photoUrl,
      'is_new_user': instance.isNewUser,
      'onboarding_completed': instance.onboardingCompleted,
      'profile_completion_percentage': instance.profileCompletionPercentage,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'address': instance.address,
      'student_id': instance.studentId,
      'ug_college': instance.ugCollege,
      'pg_college': instance.pgCollege,
      'affiliated_organisation': instance.affiliatedOrganisation,
      'current_designation': instance.currentDesignation,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
