import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/repositories/check_update_util.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:ydsd/channel/index.dart';
import '../common/index.dart';
import '../ui/index.dart';
import '../notifiers/index.dart';
class MinePagePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MinePageState();
  }

}

class MinePageState extends State<MinePagePage> {
  String version;

  @override
  void initState() {
    super.initState();
    setState(() {
       _doGetVersion();
    });

  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "我的",
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildHeadWidget(context),
            Container(
              color: Color(0xffF3F4F5),
              height: 8,
            ),
            buildItem("客服微信",null,(){Navigator.of(context).pushNamed(PageName.feedback);}),
            buildItem("检查更新","当前版本V$version",(){CheckUpdateUtil.checkUpdate(true, context);}),
            buildItem("关于我们",null,(){Navigator.of(context).pushNamed(PageName.about);}),

          ],
        ),
      )
    );
  }

  Widget buildHeadWidget(context) {
    return InkWell(
      onTap: (){ Navigator.of(context).pushNamed(PageName.userInfo);},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 16, top: 24, bottom: 24),
        color: Color(0xff2B61FF),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/head_img_def.png",
              height: 64,
              width: 64,
              fit: BoxFit.scaleDown,
            ),
            Container(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 210,
                  child:
                Text(
                  Global.profile?.user?.org_name??"",
                  style:
                  TextStyle(
                      color: Color(0xffffffff),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),),
                Container(
                  width: 1,
                  height: 8,
                ),
                Container(
                  width: 200,
                  child: Text(
                    Global.profile?.user?.login_name??"",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Color(0xffffffff),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 22),
              child: Image.asset(
                "assets/images/select_fff.png",
                height: 15,
                width: 15,
                fit: BoxFit.scaleDown,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(String title, String title2,  Function() click) {
    return  InkWell(
      child: Container(
        padding: EdgeInsets.only( left: 24),
        color: Colors.white,
        child:Container(
          padding: EdgeInsets.only(right:29),
          decoration: BoxDecoration(
              color: Colors.white,
              border:Border(bottom: BorderSide(color: Color(0xffeeeeee),width: 0.5))
          ),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(padding: EdgeInsets.only( top: 16,bottom: 16),
                child: Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xff333333),
                      fontSize: 16),
                ),),
              Row(
                children: <Widget>[
                  Text(
                    title2??"",
                    style: TextStyle(
                        color: Color(0xff999999),
                        fontSize: 12),
                  ),
                  Image.asset(
                    "assets/images/select_right.png",
                    height: 16,
                    width: 16,
                    fit: BoxFit.scaleDown,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      onTap: click,
    );
  }

  Future<void> _doGetVersion() async {
    PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = _packageInfo.version;
    });
  }
}
