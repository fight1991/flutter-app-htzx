
import 'dart:async';
import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/channel/app_method_channel.dart';
import 'package:ydsd/common/common_mixin.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/events/bn_cid_event.dart';
import 'package:ydsd/events/dis_connected_success_event.dart';
import 'package:ydsd/events/global_event_bus.dart';
import 'package:ydsd/events/scan_cid_event.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/ui/dialog/dialog_confirm.dart';
import 'package:ydsd/ui/index.dart';
import 'package:provider/provider.dart';

class BNScanPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return BNScanState();
  }

}
class BNScanState extends State<BNScanPage> with UtilWidgetMixin{
  FocusNode focusNode = FocusNode();
  ScanNotifier _notifier;

  StreamSubscription<BNCidEvent> eventCIdBus;

  StreamSubscription<DisConnectedSuccessEvent> eventDisconnect;
  var args;
  @override
  void didUpdateWidget(BNScanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("=====didUpdateWidget");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("=====deactivate");
  }

  bool stateReadable = true;
  @override
  void initState() {
    super.initState();
    _notifier = ScanNotifier(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doRequestFocus();
    });
    focusNode.addListener(() {
      print("focus node listener.... ${focusNode.toString()}");
    });
    eventCIdBus = GlobalEventBus().event.on<BNCidEvent>().listen((event) async {
        print("event ScanCidEvent");
        if(event.cid==null||event.cid==""){
          Toast.show("不能识别的卡");
          return;
        }
        if(stateReadable){
          print("空闲空闲空闲空闲空闲空闲空闲空闲");
          stateReadable = false;
          String cid = event.cid;
          print("cid=$cid");
          await _notifier.getCarDetailByCid(cid);
          _buildScanResult(_notifier);
        }else{
          print("忙碌忙碌忙碌忙碌忙碌忙碌忙碌忙碌");
        }

    });
    eventDisconnect = GlobalEventBus().event.on<DisConnectedSuccessEvent>().listen((event) async {
      print("========================");
      showAlert(
          context: context,
          title: "设备已断开",
          content: null,
          rightBtnText: "我知道了",
          leftBtnText: null,
          rightBtnCallback: () {
            Navigator.of(context).pushNamedAndRemoveUntil(PageName.main, ModalRoute.withName('/'),);
          });

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    eventCIdBus?.cancel();
    eventDisconnect?.cancel();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "发起收款",
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

  Widget _buildBody() {
   return Container(
     width: double.infinity,
     child: Stack(
       children: <Widget>[
         Container(
             color: Colors.white,
             child: SingleChildScrollView(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: <Widget>[
                   Container(margin: EdgeInsets.only(top: 48),
                     child: Image.asset(
                       "assets/images/scan_device.png",
                       height: 73,
                       width: 73,
                       fit: BoxFit.scaleDown,
                     ),
                   ),
                   Padding(padding: EdgeInsets.only(top: 12),
                     child:  Text(
                       "准备扫描",
                       style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff2B61FF),fontSize: 24),
                     ),
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 32,left: 36,right: 36),
                     padding: EdgeInsets.only(top: 24,bottom: 24),
                     decoration: BoxDecoration(
                         color: Color(0xffE9EFFF),
                         borderRadius: BorderRadius.all(Radius.circular(12))
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: <Widget>[
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: <Widget>[
                             Image.asset(
                               "assets/images/scan_info.png",
                               height: 16,
                               width: 16,
                               fit: BoxFit.scaleDown,
                             ),
                             Text(
                               "  请靠近车头对准电子车牌",
                               style: TextStyle(  color: Color(0xff2B61FF),fontSize: 14),
                             ),
                           ],
                         ),
                         Container(height: 8,),
                         Text(
                           "轻按扫描键",
                           style: TextStyle(  color: Color(0xff2B61FF),fontSize: 14),
                         ),
                       ],
                     ),
                   ),
                   RawKeyboardListener(
                     focusNode: focusNode,
                     child: TextField(
                       readOnly: true,
                       decoration: InputDecoration(
                         border: InputBorder.none,
                       ),
                     ),
                     onKey: (RawKeyEvent event){
                       if(event is RawKeyUpEvent){
                         print("onkeyUp:${event.toString()}");
                         RawKeyUpEvent rawKeyDownEvent = event;
                         if(rawKeyDownEvent.data is RawKeyEventDataAndroid ){
                           ///RawKeyEventDataAndroid(keyLabel: null flags: 8, codePoint: 0, keyCode: 135, scanCode: 63, metaState: 0, modifiers down: {})
                           RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
                           print("start onKey=======>${rawKeyEventDataAndroid?.toString()}");

                         }

                       }

                     },
                   ),
                 ],
               ),
             )
         ),

       ],
     ),
   );
  }


  void doRequestFocus() {
    print("focus======");
    FocusScope.of(context).requestFocus(focusNode);
    FocusScope.of(context).autofocus(focusNode);
  }

  ///该电子车牌未绑定银行卡， 无法发起收款
  void _showNoBankDialog({String msg}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog.simple(
          contentText: msg??"该电子车牌未绑定银行卡， 无法发起收款",
          leftBtnText: null,
          leftBtnCallback:null,
          rightBtnText: "我知道了",
          rightBtnCallback: () {
            Navigator.of(context).pop();
            setState(() {
              stateReadable = true;
            });

            },
        );

      },
    ).then((value){
      setState(() {
        stateReadable = true;
      });
    });
  }

  ///该电子车牌未绑定航天智行 APP
  void _showUnBindAppDialog({String msg}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog.simple(
          contentText: msg??"该电子车牌未绑定航天智行 APP",
          leftBtnText: null,
          leftBtnCallback:null,
          rightBtnText: "确定",
          rightBtnCallback: () {
            Navigator.of(context).pop();
            setState(() {
              stateReadable = true;
            });
          },
        );

      },
    ).then((value){
      setState(() {
        stateReadable = true;
      });
    });
  }

  ///有未完成的订单，请先处理
  void _showHasOrderInservice(String orderId,{String msg}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog.simple(
          contentText:msg?? "有未完成的订单，请先处理",
          leftBtnText: null,
          leftBtnCallback:null,
          rightBtnText: "查看订单",
          rightBtnCallback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(PageName.orderDetail,arguments: {OrderDetailPage.ORDER_NO:orderId}).then((value){
              setState(() {
                stateReadable = true;
              });
            });

          },
        );

      },
    ).then((value){
      setState(() {
        stateReadable = true;
      });
    });
  }

  void _buildScanResult(ScanNotifier notifier) {
    print("===========_buildScanResult============= code:${notifier.errorCode},carNo:${notifier?.cidCarDetail?.plate_number},orderNo:${notifier?.cidCarDetail?.trade_order_no}");

    Future.delayed(Duration(milliseconds: 10),(){
      if(notifier.errorCode==ScanNotifier.ERROR_UNBIND_BANK){
        _showNoBankDialog(msg:notifier.errorMsg);
      }else if(notifier.errorCode==ScanNotifier.ERROR_UNBIND_APP){
        _showUnBindAppDialog(msg:notifier.errorMsg);
      }else if(notifier.errorCode==ScanNotifier.ERROR_HAS_ORDER_INSERVICE){
        _showHasOrderInservice(notifier?.cidCarDetail?.trade_order_no,msg:notifier.errorMsg);
      }else if(notifier?.cidCarDetail!=null){
        Navigator.of(context).pushNamed(PageName.inputMoney,
            arguments: {InputMoneyPage.CAR_NO:notifier?.cidCarDetail?.plate_number
              ,InputMoneyPage.CID:notifier.mCid
        }).then((value){
          setState(() {
            stateReadable = true;
          });
        });
      }else{
        setState(() {
          stateReadable = true;
        });
        print("===========error=============");
      }
    });

  }

  void doDisConnect() {
    showAlert(
        context: context,
        title: "确定断开该设备连接吗",
        content: null,
        rightBtnText: "确定",
        leftBtnText: "取消",
        rightBtnCallback: () {
          AppMethodChannel.disConnectBnDevice(Global.BNDeviceAddress);
          Navigator.of(context).pop();
        },
        leftBtnCallback: () {
          Navigator.of(context).pop();
        });
  }

}