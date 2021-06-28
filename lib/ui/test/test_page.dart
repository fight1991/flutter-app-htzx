import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../../common/index.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试页面",style: TextStyle(fontWeight: FontWeight.w600),),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text("切换测试环境"),
                onPressed: () {
                  Global.isRelease = false;
                  Global.dio.options.baseUrl = Constant.rpcBaseUrlTest;
                  Global.dio.options.headers[Constant.rpcAuthenticationKey] =
                      Constant.rpcAuthenticationAppCodeTest;
                  Global.doBuildUserAgent(false);
                  Global.getPreferences().clear();
                  Global.profile.user = null;
                  Navigator.of(context).pushReplacementNamed(PageName.passwordLogin);
                },
              ),
              RaisedButton(
                child: Text("切换生产环境"),
                onPressed: () {
                  Global.isRelease = true;
                  Global.dio.options.baseUrl = Constant.rpcBaseUrlRelease;
                  Global.dio.options.headers[Constant.rpcAuthenticationKey] =
                      Constant.rpcAuthenticationAppCodeRelease;
                  Global.doBuildUserAgent(true);
                  Global.getPreferences().clear();
                  Global.profile.user = null;
                  Navigator.of(context).pushReplacementNamed(PageName.passwordLogin);
                },
              ),
              RaisedButton(
                child: Text("生成二维码"),
                onPressed: () {
                  Navigator.of(context).pushNamed(PageName.qrcodeGen);
                },
              ),
              RaisedButton(
                child: Text("扫描二维码"),
                onPressed: () {
                  Navigator.of(context).pushNamed(PageName.qrcodeScan);
                },
              ),
              RaisedButton(
                child: Text("选择图片"),
                onPressed: () {
                  Navigator.of(context).pushNamed(PageName.imagePicker);
                },
              ),
              RaisedButton(
                child: Text("登录页面"),
                onPressed: () {
                  Navigator.of(context).pushNamed(PageName.passwordLogin);
                },
              ),

              RaisedButton(
                child: Text("关于页面"),
                onPressed: () {
                  Navigator.of(context).pushNamed(PageName.about);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
