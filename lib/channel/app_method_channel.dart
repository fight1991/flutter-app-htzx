import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/http/entity/index.dart';
import 'face_auth_result.dart';

class AppMethodChannel {
  static final String _name = "com.hangtian.hongtu.ydsd/AppMethodChannel";
  static MethodChannel _methodChannel = MethodChannel(_name);

  static Future<FaceAuthResult> faceAuth(String name, String idCardNo) async {
    Map<dynamic, dynamic> result;
    try {
      result = await _methodChannel.invokeMethod("faceAuth");
    } catch (onError) {
      print("AppMethodChannel, faceAuth onError:" + onError);
    }
    if (result != null) {
      String filePath = result["base64Image"];
      String base64Image = "";
      if (filePath != null) {
        try {
          print("readAsStringSync:$filePath");
          File imageFile = File(filePath);
          base64Image = imageFile.readAsStringSync(encoding: utf8);
        } catch (e) {
          print("readAsStringSync failed,$e");
        }
      }

      return FaceAuthResult(
        isSuccess: result["resultCode"] == "0",
        resultCode: result["resultCode"],
        reason: result["reason"],
        base64Image: base64Image,
      );
    }
    return FaceAuthResult(isSuccess: false, reason: "");
  }

  static Future<bool> startMapNav(
      double lat, double lng, String address) async {
    if (lat == null || lng == null) {
      return false;
    }
    try {
      await _methodChannel.invokeMethod(
        "startMapNav",
        {
          "lat": lat,
          "lng": lng,
          "address": address,
        },
      );
      return true;
    } catch (onError) {
      print("AppMethodChannel, startMapNav onError:$onError");
      return false;
    }
  }
  static  Future<String>getLocation()async{
    String location = await _methodChannel.invokeMethod("requestLocation");
    return  location;
  }

  static String _htDeviceId;
  static Future<String> getHtDeviceId()async{
    if(_htDeviceId==null||_htDeviceId==""){
      _htDeviceId =  await _methodChannel.invokeMethod("getHtDeviceId");
    }
    return _htDeviceId;
  }


  static Future<String> huatuoScan()async{
    return   await _methodChannel.invokeMethod("huatuoScan");
  }

  static Future<bool> onUmEvent(String eventId)async{
    if(eventId==null){
      return false;
    }
    _methodChannel.invokeMethod("onUmEvent",{"eventId":eventId});
    print("onUmEvent:"+eventId);
//    Fluttertoast.showToast(msg: eventId,gravity: ToastGravity.CENTER,);
//      UmUtils.eventClick(eventId);
  }
  static Future<bool> bindAlias(String alias)async{
    if(alias==null){
      return false;
    }
    _methodChannel.invokeMethod("bindAlias",{"alias":alias});
  }

  ///获取华拓扫码枪deviceId
  static String HUATUO_DEVICE_CODE;
  static  Future<String> getHuaTuoDeviceCode() async {
    if(HUATUO_DEVICE_CODE==null||HUATUO_DEVICE_CODE.trim()==""){
      HUATUO_DEVICE_CODE = await _methodChannel.invokeMethod("huatuoDeviceCode");
    }
    return HUATUO_DEVICE_CODE;
  }

  ///判断本能设备是否已经连接
  static Future<bool> isBenNengConnected() async {
    String deviceid  = await _methodChannel.invokeMethod("bn_device_id");
    return deviceid!=null&&deviceid!="";

//    return deviceId != null && deviceId!="";
  }
  
  static  Future<String> getBNDeviceCode() async {
    return await _methodChannel.invokeMethod("bn_device_id");
  }
  
  @deprecated
  static  searchBnDevice() async {
    String deviceId =await _methodChannel.invokeMethod("bn_search_device");
  }

  @deprecated
  static connectBnDevice(String address){
//    _methodChannel.invokeMethod("bn_connect_device",{"address":address});
  }

  @deprecated
  static disConnectBnDevice(String address){
//    _methodChannel.invokeMethod("bn_disconnect_device",{"address":address});
  }
}
