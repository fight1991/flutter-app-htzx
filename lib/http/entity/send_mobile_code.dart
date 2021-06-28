import 'package:json_annotation/json_annotation.dart';

part 'send_mobile_code.g.dart';

@JsonSerializable()
class SendMobileCodeResponse {
  @JsonKey(name: "mobile")
  String mobile;
  @JsonKey(name: "image_code_onoff")
  String imageCodeOnOff;

  SendMobileCodeResponse({
    this.mobile,
    this.imageCodeOnOff,
  });

  factory SendMobileCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$SendMobileCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendMobileCodeResponseToJson(this);
}
