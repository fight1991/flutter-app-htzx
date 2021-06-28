import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/repositories/check_update_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/ui/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';

class PasswordLoginPage extends StatefulWidget {
  static final String argNameMobile = "arg_name_mobile";

  @override
  _PasswordLoginState createState() => _PasswordLoginState();
}

class _PasswordLoginState extends State<PasswordLoginPage> {
  var _arguments;
  String _mobile = "";

  bool _hasFillMobile = false;

  bool _agreeAgreement = true;
  bool _isLoginButtonEnable = false;

  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<LoginResponse>> _loginApiStatus;
  ApiStatus<AppApiResponse<UserInfo>> _userinfoApiStatus;

  TapGestureRecognizer _recognizer = TapGestureRecognizer();
  TextEditingController _controllerMobile = TextEditingController();
  TextEditingController _controllerPwd = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      CheckUpdateUtil.checkUpdate(false, context);
    });

    _recognizer.onTap = () {
      int _time = DateTime.now().millisecondsSinceEpoch;
      Navigator.of(context).pushNamed(
        PageName.webview,
        arguments: {
          WebViewPage.argNameTitle: "用户服务协议",
          WebViewPage.argNameUrl: "${H5URL.userServerLicense}?t=${_time}",
        },
      );
    };
    _controllerMobile.addListener(() {
      _doCheckLoginBtnEnable();
    });
    _controllerPwd.addListener(() {
      _doCheckLoginBtnEnable();
    });
  }

  @override
  void dispose() {
    _recognizer.dispose();
    _controllerMobile.dispose();
    _controllerPwd.dispose();
    super.dispose();
  }

  void _doCheckLoginBtnEnable() {
    setState(() {
      bool _mobileEnable =
          _controllerMobile.text != null && _controllerMobile.text.length > 0;
      bool _pwdEnable =
          _controllerPwd.text != null && _controllerPwd.text.length > 0;
      _isLoginButtonEnable = _mobileEnable && _pwdEnable;
      // print("_doCheckLoginBtnEnable:$_isLoginButtonEnable");
    });
  }

  void doLogin() {
    if (_controllerMobile.text == null || _controllerMobile.text.length < 1) {
      Toast.show(  "请输入手机号码");
      return;
    }
    if (_controllerPwd.text == null || _controllerPwd.text.length < 1) {
      Toast.show(
          "请输入密码",
         );
      return;
    }
    if (_controllerMobile.text == null || _controllerMobile.text.length > 20) {
      Toast.show(  "用户名长度不能超过20位");
      return;
    }
    if (_controllerPwd.text == null || _controllerPwd.text.length > 20) {
      Toast.show(
        "密码长度不能超过20位",
      );
      return;
    }

    if (!_agreeAgreement) {
      Toast.show(
         "请同意《用户服务协议》");
      return;
    }
    doRequestLoginApi(_controllerMobile.text, _controllerPwd.text, "");
  }

  void doSaveLoginName(String loginName) {
      SharedPreferences _prefs = Global.getPreferences();
      _prefs.setString(Constant.spKeyUserPhone, loginName);
  }

  String doFetchParam(String paramName) {
    var resultStr;
      SharedPreferences _prefs = Global.getPreferences();
      resultStr = _prefs.getString(paramName);
    return resultStr;
  }

  void doRequestLoginApi(_mobileNo, _password, _imageVerifyCode) async {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            text: '正在登录...',
          );
        });

    try {
      _loginApiStatus = new ApiStatus(context);
      print("====login===");
      var loginResponse = await _appApi.login(_mobileNo, _password);
      _loginApiStatus.apiSuccess(loginResponse);
    } catch (onError) {
      _loginApiStatus.apiError(onError);
    }print("====login emd===");
    if (_loginApiStatus.isServiceSuccess()) {
      print("loginApiStatus, isServiceSuccess");
      doSaveToken(_loginApiStatus.apiResponse?.data?.token);
      var _notifier =
          Provider.of<ProfileChangeNotifier>(context, listen: false);
      bool userInfo = await _notifier.doRequestUserinfoApi(context);
      // 记住登录名
      doSaveLoginName(_mobileNo);
      Navigator.pop(context, true);
      if (userInfo) {
        doGoNextPage();
      } else {
        Toast.show("获取用户信息失败");
      }
      return;
    }

    Navigator.pop(context, true);
    if (_loginApiStatus.getServiceCode() == 1103) {
      Toast.show("密码错误");
      return;
    }
    if (_loginApiStatus.getServiceCode() == 1106) {
      Toast.show("登录名不存在");
      return;
    }
    Toast.show(_loginApiStatus.getErrorMsg());
//    Navigator.of(context).pushNamed(PageName.orderSearch);
  }

  void doSaveToken(String token) {
    SharedPreferences _prefs = Global.getPreferences();
    _prefs.setString(Constant.spKeyToken, token);
    var _now = DateTime.now();
    int _validityTime = 1000 * 3600 * 24 * 30; //默认30天,后端没有返回这个字段,前端先这样写,后面再改吧
    int _expireTime = _now.millisecondsSinceEpoch + _validityTime;
    _prefs.setInt(Constant.spKeyTokenExpiretime, _expireTime);
    _prefs.commit();
    print("doSaveToken, token:$token, expireTime:$_expireTime");
    Global.saveTokenAndNotifierRPC(token);
  }

  void doGoNextPage() async {
    Navigator.of(context).pushReplacementNamed(PageName.main);
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context).settings.arguments;
    if (_arguments != null) {
      _mobile = _arguments[PasswordLoginPage.argNameMobile];
    }
    if(doFetchParam(Constant.spKeyUserPhone) != null) {
      _mobile = doFetchParam(Constant.spKeyUserPhone);
    }
    // print("用户名: ${doFetchParam(Constant.spKeyUserPhone)}");
    _mobile ??= "";

    if (!_hasFillMobile) {
      _controllerMobile.text = _mobile;
      _hasFillMobile = true;
    }

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        reverse: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                child: Image.asset(
                  "assets/images/login_top.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, top: 8, right: 24),
              child: TextField(
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(20)//限制长度
                ],
                autofocus: true,
                controller: _controllerMobile,
                cursorColor: Color(0xFF333333),
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "用户名",
                  labelStyle: TextStyle(color: Color(0xffCCCCCC)),
                  hintStyle: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 12,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFEBEBEB),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFEBEBEB),
                      width: 0.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, top: 0, right: 24),
              child: TextField(
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(20)//限制长度
                ],
                autofocus: true,
                controller: _controllerPwd,
                cursorColor: Color(0xFF333333),
                obscureText: true,
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "密码",
                  labelStyle: TextStyle(color: Color(0xffCCCCCC)),
                  hintStyle: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 12,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFEBEBEB),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFEBEBEB),
                      width: 0.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            Container(
              height: 48,
              margin: EdgeInsets.only(left: 20, top: 38, right: 20),
              child: FlatButton(
                onPressed: _isLoginButtonEnable ? doLogin : null,
                color: Color(0xFF2B61FF),
                disabledColor: Color(0xFFCCCCCC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  "登录",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Visibility(visible: false,
              child: Container(
                margin: EdgeInsets.only(left: 20, top: 13, right: 20),
                child: Row(
                  children: [
                    Checkbox(
                      tristate: false,
                      checkColor: Color(0xFFFFFFFF),
                      activeColor: Color(0xFF2B61FF),
                      value: _agreeAgreement,
                      onChanged: (bool newValue) {
                        print("onChanged:$newValue");
                        setState(() {
                          _agreeAgreement = newValue;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "登录即代表您同意",
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              recognizer: _recognizer,
                              text: "《航天吉光商户平台协议》",
                              style: TextStyle(
                                color: Color.fromARGB(255, 43, 98, 255),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
