import 'package:json_annotation/json_annotation.dart';
import 'package:pgme/core/models/user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final UserModel user;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'session_id')
  final String sessionId;

  @JsonKey(name: 'has_other_active_sessions', defaultValue: false)
  final bool hasOtherActiveSessions;

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    this.hasOtherActiveSessions = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
