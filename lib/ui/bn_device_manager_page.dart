import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:ydsd/channel/app_method_channel.dart';
import 'package:ydsd/common/common_mixin.dart';
import 'package:ydsd/common/global.dart';
import 'package:ydsd/common/pages_name.dart';
import 'package:ydsd/events/global_event_bus.dart';
import 'package:ydsd/events/index.dart';
import 'package:ydsd/events/scan_cid_event.dart';
import 'package:ydsd/events/search_stoped_event.dart';

class BNDeviceManagerPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return BNDeviceManagerState();
  }
}
class BNDeviceManagerState extends State<BNDeviceManagerPage> with SingleTickerProviderStateMixin, UtilWidgetMixin{
  AnimationController  rotatController;
  List<String> mDeviceList=List();
  StreamSubscription<SearchStopedEvent> eventStopSearch;
  StreamSubscription<ConnectedSuccessEvent> eventConnectSuccess;
  StreamSubscription<DeviceFoundEvent> deviceFoundSearch;
  StreamSubscription<DisConnectedSuccessEvent> eventDisconnect;

  @override
  void initState() {
    super.initState();
    rotatController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    eventStopSearch = GlobalEventBus()
        .event
        .on<SearchStopedEvent>()
        .listen((event) async {
        rotatController.stop();
    });
    eventDisconnect = GlobalEventBus().event.on<DisConnectedSuccessEvent>().listen((event) async {
      print("========================");
      showAlert(
          context: context,
          title: "连接失败了",
          content: null,
          rightBtnText: "我知道了",
          leftBtnText: null,
          rightBtnCallback: () {
            Navigator.of(context).pushNamedAndRemoveUntil(PageName.main, ModalRoute.withName('/'),);
          });

    });
    eventConnectSuccess = GlobalEventBus()
        .event
        .on<ConnectedSuccessEvent>()
        .listen((event) async {
          print("==设备连接${this.context.toString()}");
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(PageName.bnScanPage,arguments: {"address":Global.BNDeviceAddress});
    });
    deviceFoundSearch = GlobalEventBus()
        .event
        .on<DeviceFoundEvent>()
        .listen((event) async {
          if(event.devices!=null){
            setState(() {
              List<dynamic> deviceList = json.decode(event.devices);
              print("deviceList:${deviceList.toString()}");

              mDeviceList.clear();
              deviceList.forEach((element) {
                mDeviceList.add(element.toString());
              });
              print("mDeviceList.length:${mDeviceList.length}");
            });
          }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScanDevice();
    });
  }
  @override
  void dispose() {
    rotatController.dispose();
    print("====dispose=======");
    eventConnectSuccess.cancel();
    eventStopSearch.cancel();
    deviceFoundSearch.cancel();
    eventDisconnect?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "设备管理",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
      ),
      body:_buildBody(),
    );
  }

  _buildBody() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(bottom: 48),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 48),
                    child: Image.asset(
                      "assets/images/bn_disconnected.png",
                      width: 48,
                      height: 48,
                      fit: BoxFit.fill,),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      "设备已断开",
                      style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16, color: Color(0xffFE3824)),
                    ),
                  ),
                  Container(height: 40,),
                  Container(
                    margin: EdgeInsets.only(left: 16,right: 16),
                    height: 1,
                    width: double.infinity,
                    color: Color(0xffebebeb),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 16,right: 16,top: 17),
                    child: Text(
                      "可连接设备",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)),
                    ),
                  ),
                  buildDeviceList(),
                  Visibility(
                    visible: !deviceFounded(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Text(
                        "暂无可用设备",
                        style: TextStyle(fontSize: 14, color: Color(0xff999999)),
                      ),
                    ),
                  ),

                ],
              ),
            )

        ),
        Align(
          alignment: Alignment.bottomCenter,
          child:InkWell(
            child:  Container(
              decoration: BoxDecoration(
                  border:Border(top: BorderSide(color: Color(0xffeeeeee),width: 0.5))
              ),
              height: 48,
              width: double.infinity,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RotationTransition(
                    //设置动画的旋转中心
                    alignment: Alignment.center,
                    //动画控制器
                    turns: rotatController,
                    child: Image.asset(
                      "assets/images/bn_scan_device.png",
                      height: 16,
                      width: 16,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  Text(
                    "  扫描刷新",
                    style: TextStyle(fontSize:14 , color: Color(0xff2B61FF)),
                  )
                ],
              ) ,
            ),
            onTap: (){startScanDevice();},
          ),
        )
      ],
    );
  }

  buildDeviceList() {
    List<Widget> items = mDeviceList.map((e){
      List nameAddress = e.split(",");

      return InkWell(
        onTap: (){
            print("连接设备：${e.toString()}");
          doConnectDevice(nameAddress[1]);
          },
        child: Container(
            padding: EdgeInsets.only(left: 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 23),
                  child: Text(
                    "${nameAddress[0]}",
                    style: TextStyle(fontSize:16 , color: Color(0xff000000),fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8,bottom: 3),
                  child: Text(
                    "${nameAddress[1]}",
                    style: TextStyle(fontSize:14 , color: Color(0xff999999)),
                  ),
                )
              ],
            )
        )
      );
    }).toList();
    return Visibility(
      visible: deviceFounded(),
      child: (items!=null&&items.length>0)?Container(
        child: Column(
          children: items,
        ),
      ):Container(),
    );
  }

  deviceFounded() {
    print("deviceFount=${mDeviceList?.length}");
    return mDeviceList!=null&&mDeviceList.length>0;
  }



  void startScanDevice() {
    setState(() {
      mDeviceList.clear();
      rotatController.repeat();
      AppMethodChannel.searchBnDevice();
    });

  }

  void doConnectDevice(address) {
    showLoading(context,text: "连接中").then((value) {
      setState(() {
        mDeviceList.clear();
      });
    });
    Global.BNDeviceAddress = address;
    AppMethodChannel.connectBnDevice(address);
  }



}