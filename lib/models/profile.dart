import 'package:ydsd/http/entity/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  @JsonKey(name: "theme")
  int theme;
  @JsonKey(name: "locale")
  String locale;
  @JsonKey(name: "user")
  UserInfo user;
  @JsonKey(name: "last_login")
  int lastLogin;
  @JsonKey(name: "token")
  String token;

  Profile({
    this.theme,
    this.locale,
    this.user,
    this.lastLogin,
    this.token,
  });






  get showName {
    if (token == null) {
      return "请登录";
    }
    if (user == null) {
      return "加载中...";
    }
    if (user.real_name == null) {
      return "";
    } else {
      return user.real_name;
    }
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
