// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    theme: json['theme'] as int,
    locale: json['locale'] as String,
    user: json['user'] == null
        ? null
        : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
    lastLogin: json['last_login'] as int,
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'theme': instance.theme,
      'locale': instance.locale,
      'user': instance.user,
      'last_login': instance.lastLogin,
      'token': instance.token,
    };
