import 'package:flutter/material.dart';

import '../models/index.dart';
import '../common/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get profile => Global.profile;

  bool get isLogined => profile.token != null;



  Future<bool> doRequestUserinfoApi(
    BuildContext context, {
    bool clearData = false,
  }) async {
    AppApi _appApi = AppApi();
    ApiStatus<AppApiResponse<UserInfo>> _userinfoApiStatus = ApiStatus(context);
    try {
      print("_doRequestUserinfoApi");
      var apiResponse = await _appApi.getUserinfo();
      _userinfoApiStatus.apiSuccess(apiResponse);
    } catch (onError) {
      _userinfoApiStatus.apiError(onError);
      print("_doRequestUserinfoApi: $onError");
    }
    if (_userinfoApiStatus.isServiceSuccess()) {
      UserInfo user = _userinfoApiStatus.apiResponse.data;
      Global.profile.user = user;
      print("profile_change_nofifier user:${user.toJson()},global.profile.user=${Global.profile.user.toJson()}");
      notifyListeners();
      return true;
    }
    if (401 == _userinfoApiStatus.getServiceCode() || clearData) {
      Global.profile.user = null;
      Global.cleanTokenAndNotifierRPC();
      Global.getPreferences().clear();
    }
    notifyListeners();
    return false;
  }
}
