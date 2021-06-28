import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer _timer;
  var _token;
  var _expiretime;

  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<UserInfo>> _userinfoApiStatus;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
      _timer = Timer.periodic(Duration(milliseconds: 10), (Timer timer) {
        print("SplashPage, periodic");
        SharedPreferences _preferences = Global.getPreferences();
        if (_preferences != null&&Global.isInited) {
          doGoNextPage(context);
          _timer.cancel();
        }
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void doGoNextPage(BuildContext context) async {
    SharedPreferences _preferences = Global.getPreferences();
    _token = _preferences.getString(Constant.spKeyToken);
    _expiretime = _preferences.getInt(Constant.spKeyTokenExpiretime);
    _expiretime ??= -1;
    print("SplashPage, doGoNextPage, _token:$_token, _expiretime:$_expiretime");

    if (_token == null) {
      Navigator.of(context).pushReplacementNamed(PageName.passwordLogin);
    } else {
      Global.saveTokenAndNotifierRPC(_token);

      print("object _notifier.doRequestUserinfoApi");
      var _notifier =
          Provider.of<ProfileChangeNotifier>(context, listen: false);
      await _notifier.doRequestUserinfoApi(context, clearData: true);

      if (!Global.isLogin) {
        Navigator.of(context).pushReplacementNamed(PageName.passwordLogin);
        print("tologinPage");
      } else {
        Navigator.of(context).pushReplacementNamed(PageName.main);
        print("toMainPage");
//        AppMethodChannel.bindAlias(Global.profile?.user?.real_name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: Container(
                width: 96,
                height: 96,
                margin: EdgeInsets.only(bottom: 32),
                child: Image.asset(
                  "assets/images/ydsd_icon.png",
                  fit: BoxFit.fill,
                ),
              ),
              onTap: () => doGoNextPage(context),
            ),
            Container(child: Text("小蛮腰APP",style: TextStyle(color: Color(0xff000000),fontSize:16 ),),margin: EdgeInsets.only(top: 16),)
          ],
        ),
      ),
    );
  }
}
