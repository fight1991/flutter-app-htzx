import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/index.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckUpdateUtil{


  static Future<void> checkUpdate(bool isUserCheck,BuildContext context) async {
    AppApi _appApi = AppApi();
    ApiStatus<AppApiResponse<AppVersion>> _checkUpdateApiStatus;

    if(isUserCheck){
      Toast.show("正在检查更新...");
    }

    try {
      _checkUpdateApiStatus ??= ApiStatus(context);
      PackageInfo _packageInfo = await PackageInfo.fromPlatform();

      String appName = Constant.APP_NAME;
      String version = _packageInfo.version;
      String buildCode = _packageInfo.buildNumber;
      String brand = "";
      String model = "";
      String osVersion = "";
      String romVersion = "";
      String channel = "";
      String userCheck = isUserCheck ? "1" : "0";
      String lang = WidgetsBinding.instance.window.locale.toString();
      String network = "";
      String root = "0";
      String mac = "";
      String deviceid = "";

      DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var _androidDeviceInfo = await _deviceInfo.androidInfo;
        channel = "Guanwang";
        osVersion = "${_androidDeviceInfo.version.sdkInt}";
        romVersion = _androidDeviceInfo.version.release;
        brand = _androidDeviceInfo.brand;
        model = _androidDeviceInfo.model;
      } else if (Platform.isIOS) {
        var _iosDeviceInfo = await _deviceInfo.iosInfo;
        channel = "AppStore";
        osVersion = _iosDeviceInfo.systemVersion;
        romVersion = _iosDeviceInfo.systemName;
        brand = "Apple";
        model = _iosDeviceInfo.name;
      }
      print("checkAppUpdate:"
          "appName: $appName,"
          "version: $version, "
          "buildCode: $buildCode, "
          "brand: $brand, "
          "model: $model, "
          "osVersion: $osVersion, "
          "romVersion: $romVersion, "
          "channel: $channel, "
          "userCheck: $userCheck, "
          "lang: $lang, "
          "network: $network, "
          "root: $root, "
          "mac: $mac,"
          "deviceid: $deviceid,");

      var apiResponse = await _appApi.checkAppUpdate(
        appName: appName,
        appOs: "Android",
        version: version,
        buildCode: buildCode,
        brand: brand,
        model: model,
        osVersion: osVersion,
        romVersion: romVersion,
        channel: channel,
        userCheck: userCheck,
        lang: lang,
        network: network,
        root: root,
        mac: mac,
        deviceid: deviceid,
      );
      _checkUpdateApiStatus.apiSuccess(apiResponse);
    } catch (onError) {
      _checkUpdateApiStatus.apiError(onError);
      print("doCheckUpdate, apiError:$onError");
    }
    if (_checkUpdateApiStatus.isServiceSuccess()) {
      if (_checkUpdateApiStatus.apiResponse?.data?.require_install == 0 &&
          !needAlert(_checkUpdateApiStatus.apiResponse?.data)&&!isUserCheck) {
        print("not show version alert");
        return;
      }
      print("doCheckUpdate, isServiceSuccess true");
      AppVersion _data = _checkUpdateApiStatus.apiResponse?.data;
      if (_data != null && _data.download_url != null) {
        int requireInstall = _data.require_install;
        String _title = _data.title;
        String _description = _data.description;
        _title ??= "发现新版本";
        _description ??= "";
        showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ConfirmDialog.simple(
              willPopScope: requireInstall == 0,
              titleText: _title,
              contentText: _description,
              leftBtnText: requireInstall != 0 ? null : "以后再说",
              leftBtnCallback: requireInstall != 0
                  ? null
                  : () {
                Navigator.of(context).pop();
              },
              rightBtnText: "立即更新",
              rightBtnCallback: () {
                if (_checkUpdateApiStatus.apiResponse?.data?.require_install ==
                    0) {
                  Navigator.of(context).pop();
                }
                _doUpdateApp(_data.download_url);
              },
            );

          },
        );
        return;
      }
    }
    if(isUserCheck){
      Toast.show("当前已是最新版本");
    }
    return;
  }
  static void  _doUpdateApp(String _url) async {
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      Toast.show("下载更新失败");
    }
  }
  static bool  needAlert(AppVersion data) {
    if (data == null) {
      return false;
    }
    print("do check need alert ");
    int timeSecond = int.parse(data.remind_frequency.toString());
    print("remid_frequency: " + data.remind_frequency);
    SharedPreferences _preferences = Global.getPreferences();
    int lastTime = _preferences.getInt(SP_KEY.APP_VERSION_ALERT_TIME);

    if (lastTime != null && lastTime > 0) {
      int timeNowMill = new DateTime.now().millisecondsSinceEpoch;
      if ((timeNowMill - lastTime).abs() < timeSecond * 1000) {
        return false;
      }
    }
    _preferences.setInt(SP_KEY.APP_VERSION_ALERT_TIME,
        new DateTime.now().millisecondsSinceEpoch);
    return true;
  }
}