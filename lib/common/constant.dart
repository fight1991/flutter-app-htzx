import 'package:ydsd/common/global.dart';

class H5URL {
  static String helpCenter = Global.isRelease
      ? "https://ht-ht-app.obs-website.cn-east-3.myhuaweicloud.com/help/index.html"
      : "https://ht-ht-app-test.obs-website.cn-east-3.myhuaweicloud.com/app/help/index.html"; //帮助中心
  static String userServerLicense = Global.isRelease
      ? "https://ht-ht-app.obs-website.cn-east-3.myhuaweicloud.com/license/index.html"
      : "https://ht-ht-app-test.obs-website.cn-east-3.myhuaweicloud.com/app/license/index.html"; //用户注册协议和隐私政策

  static String bindEplateProtocol = Global.isRelease
      ? "https://ht-ht-app.obs-website.cn-east-3.myhuaweicloud.com/license/bindProtocol.html"
      : "https://ht-ht-app-test.obs-website.cn-east-3.myhuaweicloud.com/app/license/bindProtocol.html"; //电子车牌绑定协议：
}

class Constant {
  //测试
//  static final String rpcBaseUrlTest = "https://htv2x.997icu.com";
  static final String rpcBaseUrlTest = "https://mapi-test.htjiguang.cn/eplate";
  static final String rpcAuthenticationAppCodeTest =
      "44899ae6cd87431faae3b9edfad1d540b77ab8ed47364048bee4a78601442c10";
//  static final String rpcAuthenticationAppCodeTest =
//      "4d147b569d084fcba629dc9d91092af557093a7f5fb243f1baf20a6e1d195b99";

  //生产
  static final String rpcBaseUrlRelease = "https://mapi.htjiguang.cn/eplate";
  static final String rpcAuthenticationAppCodeRelease =
      "f6d2d9599239420a9539051f833d8c40e5df814999ad4f86ad0048832d5fbce5";

  static final String rpcAuthenticationKey = "X-Apig-AppCode";
  static final String rpcDeviceIdKey = "HT-Client-DeviceId";
  static final String rpcClientTimeKey = "HT-Client-Time";
  static final String spKeyToken = "sp_key_token";
  static final String spKeyTokenExpiretime = "sp_key_token_expiretime";

  //用户手机号
  static final String spKeyUserPhone = "sp_key_user_phone";
  static final String APP_NAME = "com.hangtian.hongtu/ydsd";

  static final String homePageEventChannel =
      "com.hangtian.hongtu.ydsd/HomePageEventChannel";
  static final String globalEventChannel =
      "com.hangtian.hongtu.ydsd/GlobalEventChannel";
}

class SP_KEY {
  static final String APP_VERSION_ALERT_TIME = "APP_VERSION_ALERT_TIME";
}
