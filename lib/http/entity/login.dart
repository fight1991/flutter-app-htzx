import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class LoginResponse {
  @JsonKey(name: "login_name")
  String login_name;
  @JsonKey(name: "mobile")
  String mobile;
  @JsonKey(name: "nick_name")
  String nick_name;
  @JsonKey(name: "real_name")
  String real_name;
  @JsonKey(name: "status")
  String status;
  @JsonKey(name: "telephone")
  String telephone;
  @JsonKey(name: "token")
  String token;
  @JsonKey(name: "token_expired")
  int token_expired;

  LoginResponse({this.login_name, this.mobile, this.nick_name, this.real_name, this.status, this.telephone, this.token, this.token_expired});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      login_name: json['login_name'] as String,
      mobile: json['mobile']  as String,
      nick_name: json['nick_name']  as String,
      real_name: json['real_name'] as String,
      status: json['status'] as String,
      telephone: json['telephone'] as String,
      token: json['token'] as String,
      token_expired: json['token_expired'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login_name'] = this.login_name;
    data['mobile'] = this.mobile;
    data['nick_name'] = this.nick_name;
    data['real_name'] = this.real_name;
    data['status'] = this.status;
    data['telephone'] = this.telephone;
    data['token'] = this.token;
    data['token_expired'] = this.token_expired;
    return data;
  }
}
