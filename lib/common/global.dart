import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/channel/app_event_channel.dart';
import 'package:ydsd/channel/index.dart';
import 'package:ydsd/common/environment_config.dart';
import 'package:ydsd/common/pages_name.dart';
import 'package:ydsd/http/rpc_auth_interceptor.dart';
import 'package:ydsd/http/rpc_time_interceptor.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../http/index.dart';
import "../models/index.dart";
import "constant.dart";

const List<MaterialColor> _themes = [
  Colors.blue,
  Colors.cyan,
  Colors.red,
  Colors.amber,
  Colors.green,
  Colors.blueGrey,
];

class Global {
  static String BNDeviceAddress;//
  static Profile profile = Profile();
  static SharedPreferences _preferences;
  static PackageInfo _packageInfo;
  static DeviceInfoPlugin _deviceInfo;
  static AndroidDeviceInfo _androidDeviceInfo;
  static IosDeviceInfo _iosDeviceInfo;
  static Dio dio = Dio();

  static List<MaterialColor> get themes => _themes;

//  static bool isRelease = bool.fromEnvironment("dart.vm.product");
  static bool isRelease = EnvironmentConfig.isRelease; //默认生产
  static String _userAgentKey = "User-Agent";
  static String _userAgentValue;
  static String _rpcAppCode = isRelease
      ? Constant.rpcAuthenticationAppCodeRelease
      : Constant.rpcAuthenticationAppCodeTest;
  static String _rpcAuthKey = Constant.rpcAuthenticationKey;
  static String _rpcUserAuthKey = "Authorization";
  static String _rpcUserAuthValue = "";

  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  static bool get isLogin {
    print("global.isLogin user=${profile.user}");
    return profile.token != null &&
        profile.user != null  ;
  }

  static SharedPreferences getPreferences() {
    return _preferences;
  }

  static bool isInited = false;
  static init() async {
    var timeStart = DateTime.now().millisecondsSinceEpoch;
    print("==========Global.init is start.....isRelease:"+isRelease.toString()+"===========");
    WidgetsFlutterBinding.ensureInitialized();
    print("_WidgetsFlutterBinding init finish.");
    _preferences = await SharedPreferences.getInstance();
    print("_preferences init finish.");

    _packageInfo = await PackageInfo.fromPlatform();
    print("_packageInfo init finish.");

    _deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _androidDeviceInfo = await _deviceInfo.androidInfo;
      print("_androidDeviceInfo init finish.");
    } else if (Platform.isIOS) {
      _iosDeviceInfo = await _deviceInfo.iosInfo;
      print("_iosDeviceInfo init finish.");
    }

    _initUserAgent();

    _initDio();

    _initEventChannel();
    var timeCost = DateTime.now().millisecondsSinceEpoch-timeStart;
    isInited = true;
    print("global init finished timeCost:$timeCost");

  }

  static saveTokenAndNotifierRPC(String token) {
    print("Global saveToken:$token");
    print("Global set rpc header:Bearer ${token}");
    _rpcUserAuthValue = "Bearer ${token}";
    dio.options.headers[_rpcUserAuthKey] = _rpcUserAuthValue;
    Global.profile.token = token;
  }

  static cleanTokenAndNotifierRPC() {
    print("Global cleanTokenAndNotifierRPC");
    _rpcUserAuthValue = "";
    dio.options.headers[_rpcUserAuthKey] = "";


    Global.profile.token = null;
  }

  static doLogout() {
    print("Global doLogout");
    try {
      Future.delayed(Duration(milliseconds: 50),(){
        Global.navigatorKey.currentState.pushNamed(PageName.passwordLogin);
      });
    } catch (error) {
      print("Global doLogout,error:$error");
    }
  }

  static _initDio() {
    dio.interceptors.clear();
    dio.interceptors.add(RpcTimeInterceptor());
    dio.interceptors.add(RpcAuthInterceptor());
    dio.interceptors.add(MockInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (Object object) {
          print(object);
        },
      ),
    );

//    dio.options.baseUrl =
//        isRelease ? Constant.rpcBaseUrlRelease : Constant.rpcBaseUrlTest;
    dio.options.connectTimeout = 50000;
    dio.options.receiveTimeout = 30000;
    dio.options.headers[_rpcAuthKey] = _rpcAppCode;
    dio.options.headers[_userAgentKey] = _userAgentValue;
    
    print("_initDio init finish.");
  }

  static _initUserAgent() {
    //release,android,com.borrow.anytime/2.3.1,okhttp/3.8.0,Baidu,Android/5.1,samsung/SM-J5008
    String env = isRelease ? "release" : "debug";
    String platform = "unkown"; //平台
    String appPackage = _packageInfo.packageName; //App的包名
    String appVersion = _packageInfo.version; //App的版本
    String rpcName = "dio"; //RPC组件
    String rpcVersion = "3.0.9"; //RPC组件的版本
    String channel = "unkown"; //App发布渠道
    String osName = "unkown"; //ROM的类型
    String osVersion = "unkown"; //操作系统的版本
    String brand = "unkown"; //手机厂商
    String phoneModel = "unkown"; //手机型号

    if (Platform.isAndroid) {
      platform = "android";
      channel = "Guanwang";
      osName = "Android";
      osVersion = "${_androidDeviceInfo.version.sdkInt}";
      brand = _androidDeviceInfo.brand;
      phoneModel = _androidDeviceInfo.model;
    } else if (Platform.isIOS) {
      platform = "ios";
      channel = "AppStore";
      osName = _iosDeviceInfo.systemName;
      osVersion = _iosDeviceInfo.systemVersion;
      brand = "Apple";
      phoneModel = _iosDeviceInfo.name;
    } else if (Platform.isWindows) {
      platform = "windows";
    } else if (Platform.isLinux) {
      platform = "linux";
    } else if (Platform.isMacOS) {
      platform = "macOS";
    }
    _userAgentValue =
        "$env,$platform,$appPackage/$appVersion,$rpcName/$rpcVersion,$channel,$osName/$osVersion,$brand/$phoneModel";
    print("_initUserAgent:$_userAgentValue");
  }

  static doBuildUserAgent(bool release) {
    //release,android,com.borrow.anytime/2.3.1,okhttp/3.8.0,Baidu,Android/5.1,samsung/SM-J5008
    String env = release ? "release" : "debug";
    String platform = "unkown"; //平台
    String appPackage = _packageInfo.packageName; //App的包名
    String appVersion = _packageInfo.version; //App的版本
    String rpcName = "dio"; //RPC组件
    String rpcVersion = "3.0.9"; //RPC组件的版本
    String channel = "unkown"; //App发布渠道
    String osName = "unkown"; //ROM的类型
    String osVersion = "unkown"; //操作系统的版本
    String brand = "unkown"; //手机厂商
    String phoneModel = "unkown"; //手机型号

    if (Platform.isAndroid) {
      platform = "android";
      channel = "Guanwang";
      osName = "Android";
      osVersion = "${_androidDeviceInfo.version.sdkInt}";
      brand = _androidDeviceInfo.brand;
      phoneModel = _androidDeviceInfo.model;
    } else if (Platform.isIOS) {
      platform = "ios";
      channel = "AppStore";
      osName = _iosDeviceInfo.systemName;
      osVersion = _iosDeviceInfo.systemVersion;
      brand = "Apple";
      phoneModel = _iosDeviceInfo.name;
    } else if (Platform.isWindows) {
      platform = "windows";
    } else if (Platform.isLinux) {
      platform = "linux";
    } else if (Platform.isMacOS) {
      platform = "macOS";
    }
    _userAgentValue =
        "$env,$platform,$appPackage/$appVersion,$rpcName/$rpcVersion,$channel,$osName/$osVersion,$brand/$phoneModel";
    print("_initUserAgent:$_userAgentValue");
    dio.options.headers[_userAgentKey] = _userAgentValue;
  }

  static void _initEventChannel() {
    AppEventChannel.registerPushEvent();
  }

  ///是否是本能设备
  static bool isBenNengDevice(){
    return profile?.user?.device_provider!="华拓";
  }

  static AndroidDeviceInfo getAndroidDeviceInfo(){
    return _androidDeviceInfo;
  }
}
