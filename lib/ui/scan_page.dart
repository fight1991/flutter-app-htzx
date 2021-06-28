
import 'dart:async';
import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/channel/app_method_channel.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/events/global_event_bus.dart';
import 'package:ydsd/events/scan_cid_event.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/ui/dialog/dialog_confirm.dart';
import 'package:ydsd/ui/index.dart';
import 'package:provider/provider.dart';

class ScanPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ScanState();
  }

}
class ScanState extends State<ScanPage>{
  FocusNode focusNode = FocusNode();
  ScanNotifier _notifier;

  StreamSubscription<ScanCidEvent> eventBus;
  @override
  void initState() {
    super.initState();
    _notifier = ScanNotifier(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doRequestFocus();
    });
    focusNode.addListener(() {
      print("focus node listener....");
    });

    eventBus = GlobalEventBus().event.on<ScanCidEvent>().listen((event) async {
      print("event ScanCidEvent");
        String cid = event.cid;
        await _notifier.getCarDetailByCid(cid);
        _buildScanResult(_notifier);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    eventBus.cancel();
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
//     onTap: (){
//       doRequestFocus();
//     },
     child: Container(
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
                   RawKeyUpEvent rawKeyDownEvent = event;
                   if(rawKeyDownEvent.data is RawKeyEventDataAndroid ){
                     ///RawKeyEventDataAndroid(keyLabel: null flags: 8, codePoint: 0, keyCode: 135, scanCode: 63, metaState: 0, modifiers down: {})
                     RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
                     print("start onKey=======>${rawKeyEventDataAndroid?.toString()}");
                     if ( rawKeyEventDataAndroid?.keyCode == 135) {
                       _doScan();
                     }
                   }

                 }

               },
             ),
           ],
         ),
       )
     ),
   );
  }
  ///启动扫码枪扫码
  Future<void> _doScan() async {
    await  AppMethodChannel.huatuoScan();
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
          },
        );

      },
    );
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
          },
        );

      },
    );
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
            Navigator.of(context).pushNamed(PageName.orderDetail,arguments: {OrderDetailPage.ORDER_NO:orderId});

          },
        );

      },
    );
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

        });
      }else{
        print("===========error=============");
      }
    });

  }

}