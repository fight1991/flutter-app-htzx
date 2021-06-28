import 'package:flutter/services.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/events/bn_cid_event.dart';
import 'package:ydsd/events/global_event_bus.dart';
import 'package:ydsd/events/index.dart';
import 'package:ydsd/events/scan_cid_event.dart';
import 'package:ydsd/events/search_stoped_event.dart';
import 'package:ydsd/notifiers/index.dart';

class AppEventChannel {
  static void registerPushEvent() {
    print("registerPushEvent");
    EventChannel _eventChannel;
    _eventChannel = EventChannel(Constant.homePageEventChannel);
    _eventChannel.receiveBroadcastStream().listen((event) {
      if(event is Map){
        String eName = event["event"];
        print("======eventChannel==>$eName");
        if("uri"==eName){
          String uriStr = event["uri"];
          if(uriStr!=null&&uriStr.isNotEmpty){
            print("eventChannel uri:$uriStr");
            doUriEvent(uriStr);
          }
        }else if("aliyunpush" == eName){
          print("doRequestUnreadMsgCountApi:$event");
          MessageChangeNotifier.singleton.doRequestUnreadMsgCountApi();
        }else if("scan" == eName){
          String cid = event["cid"];
          print("===>cid$cid");
          GlobalEventBus().event.fire(ScanCidEvent(cid));
        }else if("bn_device_found" == eName){
            String deviceList = event["devices"];
            GlobalEventBus().event.fire(DeviceFoundEvent(deviceList));
            print("found bnDevice:$deviceList");
        }else if("bn_search_stop" == eName){
          GlobalEventBus().event.fire(SearchStopedEvent());
        }else if("bn_connected" == eName){
          GlobalEventBus().event.fire(ConnectedSuccessEvent());
        }else if("bn_discnnected" == eName){
          print("=============DisConnectedSuccessEvent===========");
          GlobalEventBus().event.fire(DisConnectedSuccessEvent());
        }else if("bn_cid" == eName){
          String cid = event["cid"];
          GlobalEventBus().event.fire(BNCidEvent(cid));
        }else if("bn_device_alarm" == eName){

        }
        return;
      }

    });
  }

  static void doUriEvent(String uriStr) {
    if(uriStr==null||uriStr.isEmpty){
      return;
    }
    Uri uri = Uri.parse(uriStr);
    print("uri.path = "+uri.path);
    if("/pwdlogin"==uri.path){
      //跳转密码登录
      Global.navigatorKey.currentState.pushNamed(PageName.passwordLogin);
    }
  }
}
