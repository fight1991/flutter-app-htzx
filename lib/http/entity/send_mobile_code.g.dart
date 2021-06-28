// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_mobile_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMobileCodeResponse _$SendMobileCodeResponseFromJson(
    Map<String, dynamic> json) {
  return SendMobileCodeResponse(
    mobile: json['mobile'] as String,
    imageCodeOnOff: json['image_code_onoff'] as String,
  );
}

Map<String, dynamic> _$SendMobileCodeResponseToJson(
        SendMobileCodeResponse instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
      'image_code_onoff': instance.imageCodeOnOff,
    };
