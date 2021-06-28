import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/channel/index.dart';
import 'package:ydsd/common/common_mixin.dart';
import 'package:ydsd/common/environment_config.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/repositories/check_update_util.dart';
import 'package:ydsd/ui/index.dart';
import 'package:provider/provider.dart';

import '../common/global.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>   with UtilWidgetMixin{
  int lastBackTime = DateTime.now().millisecondsSinceEpoch;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      CheckUpdateUtil.checkUpdate(false, context);
      showScanPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: MessageChangeNotifier.singleton),
      ],
      child: WillPopScope(
        onWillPop: ()async{
          int time = DateTime.now().millisecondsSinceEpoch;
          if(time-lastBackTime>1000){
            Toast.show("再按一次退出");
            lastBackTime = time;
            return false;
          }
          return true;
        },
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                color: Color(0xffffffff),
                margin: EdgeInsets.all(24),
                padding: EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/images/head_img_def.png",
                                  height: 35,
                                  width: 35,
                                  fit: BoxFit.scaleDown,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: Container(
                                      width: 240,
                                      child: Text(
                                        Global.profile.user?.org_name??"",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Color(0xff333333),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                )
                              ],
                            ),
                            Image.asset(
                              "assets/images/select_right.png",
                              height: 16,
                              width: 16,
                              fit: BoxFit.scaleDown,
                            ),
                          ]),
                      onTap: () {
                        Navigator.of(context).pushNamed(PageName.minePage);
                      },
                    ),
                    InkWell(
                      onTap: () {
                         showScanPage();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        padding: EdgeInsets.only(left: 24),
                        margin: EdgeInsets.only(top: 26),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            image: DecorationImage(
                                image: AssetImage("assets/images/main_top.png"),
                                fit: BoxFit.fill)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image.asset(
                              "assets/images/price_input.png",
                              height: 56,
                              width: 56,

                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 18),
                              child: TextArrow("发起收款"),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(PageName.orderList);
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          margin: EdgeInsets.only(top: 32),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage("assets/images/main_bottom.png"),
                              )),
                          child: TextArrow("订单管理")),
                    ),
                  ],
                ),
              ),
            )),
      )
    );
  }

  Future<void> showScanPage() async {
    if(Global.isBenNengDevice()){
      //本能2.0,被夹式不在维护，便于代码可读性，背夹式全部删除 @无缺
        //判断是否连接设备
//        showLoading(context,text: "加载中...");
//        print("showLoading.....");
//        bool isConnected = await AppMethodChannel.isBenNengConnected();
//        Navigator.of(context).pop();
//        if(!isConnected){
//          //绑定设备
//          Navigator.of(context).pushNamed(PageName.bNDeviceManagerPagePage);
//          return;
//        }

        Navigator.of(context).pushNamed(PageName.bnScanPage);
        return;
    }
    Navigator.of(context).pushNamed(PageName.scanPage);
  }
}

// ignore: must_be_immutable
class TextArrow extends StatelessWidget {
  String txt;
  TextArrow(this.txt);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            this.txt,
            style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            height: 16,
            width: 16,
            child: Image.asset(
              "assets/images/select_fff.png",
              fit: BoxFit.scaleDown,
            ),
          )
        ],
      ),
    );
  }
}
