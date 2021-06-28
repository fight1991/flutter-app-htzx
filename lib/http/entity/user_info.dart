import 'package:json_annotation/json_annotation.dart';


///车辆信息
@JsonSerializable()
class UserInfo {

  @JsonKey(name: "real_name")
  final String real_name;
  @JsonKey(name: "org_name")
  final String org_name;
  @JsonKey(name: "login_name")
  String login_name;
  @JsonKey(name: "mobile")
  String mobile;
  @JsonKey(name: "nick_name")
  String nick_name;
  @JsonKey(name: "status")
  String status;
  @JsonKey(name: "telephone")
  String telephone;
  @JsonKey(name: "device_provider")
  String device_provider;

  UserInfo({this.login_name, this.mobile, this.nick_name, this.org_name, this.real_name, this.status, this.telephone, this.device_provider});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      login_name: json['login_name'],
      mobile: json['mobile'],
      nick_name: json['nick_name'],
      org_name: json['org_name'],
      real_name: json['real_name'],
      status: json['status'],
      telephone: json['telephone'],
      device_provider: json['device_provider'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login_name'] = this.login_name;
    data['mobile'] = this.mobile;
    data['nick_name'] = this.nick_name;
    data['org_name'] = this.org_name;
    data['real_name'] = this.real_name;
    data['status'] = this.status;
    data['telephone'] = this.telephone;
    data['device_provider'] = this.device_provider;
    return data;
  }
}
