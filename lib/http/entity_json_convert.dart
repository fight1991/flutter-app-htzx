import 'package:ydsd/i18n/messages_en_US.dart';

import 'entity/index.dart';

class AppApiJsonConvert {
  static Object convert<T>(json, T) {
    if (json == null) {
      return null;
    }
    if (T == String || T == int || T == double) {
      return json;
    }

    if (T == SendMobileCodeResponse) {
      return SendMobileCodeResponse.fromJson(json);
    }
    if (T == LoginResponse) {
      return LoginResponse.fromJson(json);
    }
    if (T == CidCarDetail) {
      return CidCarDetail.fromJson(json);
    }
    if (T == OrderListResponse) {
      return OrderListResponse.fromJson(json);
    }
    if (T == OrderDetailResponse) {
      return OrderDetailResponse.fromJson(json);
    }
    if (T == OrderItem) {
      return OrderItem.fromJson(json);
    }
    if (T == UserInfo) {
      return UserInfo.fromJson(json);
    }

    if (T == AppVersion) {
      return AppVersion.fromJson(json);
    }
    throw UnsupportedError("$T");
  }

  static List<T> convertList<T>(json) {
    print("AppApiJsonConvert, convertList:$T");
    if (json == null) {
      return null;
    }
    if (json is List) {
      List<T> result = List();
      List jsonList = json as List;
      for (int i = 0; i < jsonList.length; i++) {
        result.add(convert(jsonList.elementAt(i), T));
      }
      return result;
    }
    throw UnsupportedError("$T");
  }
}
