import 'package:ydsd/common/index.dart';
import 'package:ydsd/http/apis/app_api.dart';
import 'package:ydsd/http/apis/app_update_api.dart';

class URL_Config {
  static getUrl(String apiName) {
    String url = "";
    switch (apiName) {
      case AppApi.ApiName:
        url = Global.isRelease
            ? Constant.rpcBaseUrlRelease
            : "https://mapi-test.htjiguang.cn/eplate";
        break;
    }
    return url;
  }
}
