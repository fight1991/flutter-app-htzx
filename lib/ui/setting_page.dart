import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydsd/ui/index.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ydsd/channel/index.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<AppVersion>> _checkUpdateApiStatus;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void doCheckUpdate(bool isUserCheck) async {
    //
    AppMethodChannel.onUmEvent("M060200");
    Fluttertoast.showToast(
        msg: "正在检查更新...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER);
    _checkUpdateApiStatus ??= ApiStatus(context);
    try {
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
              leftBtnText: requireInstall != 0 ? null : "取消",
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
    Fluttertoast.showToast(
        msg: "当前已是最新版本",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER);
    return;
  }

  void _doUpdateApp(String _url) async {
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      Fluttertoast.showToast(
          msg: "下载更新失败",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
    }
  }

  void doGoChangePwdPage() {
    AppMethodChannel.onUmEvent("M060100");
    Navigator.of(context).pushNamed(PageName.changePassword);
  }

  void doLogout() {
    AppMethodChannel.onUmEvent("M060300");
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog.simple(
          contentText: "确定要退出登录吗？",
          leftBtnCallback: () {
            Navigator.of(context).pop();
          },
          rightBtnCallback: () {
            _doLogout();
            //Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _doLogout() {
    SharedPreferences _preferences = Global.getPreferences();
    _preferences.clear();
    _preferences.commit();

    Global.cleanTokenAndNotifierRPC();

    Navigator.of(context).pushNamedAndRemoveUntil(
      PageName.passwordLogin,
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "设置",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset(
                "assets/images/toolbar_back.png",
                width: 16,
                height: 19,
                fit: BoxFit.scaleDown,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlatButton(
              onPressed: doGoChangePwdPage,
              color: Colors.white,
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Container(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "修改密码",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFFCCCCCC),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 1,
              width: 343,
              color: Color(0xFFF5F6F7),
              margin: EdgeInsets.only(left: 24, right: 24),
            ),
            FlatButton(
              onPressed: () => doCheckUpdate(true),
              color: Colors.white,
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Container(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "检查更新",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFFCCCCCC),
                    )
                  ],
                ),
              ),
            ),
            Spacer(),
            FlatButton(
              onPressed: doLogout,
              color: Colors.white,
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Text(
                  "退出登录",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
