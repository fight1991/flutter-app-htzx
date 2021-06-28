import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/ui/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _submitBtnEnable = false;

  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse> _resetPwdApiStatus;

  TextEditingController _controllerPwd1 = TextEditingController();
  TextEditingController _controllerPwd2 = TextEditingController();
  TextEditingController _controllerPwd3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerPwd1.addListener(() {
      _doCheckSubmitBtnEnable();
    });
    _controllerPwd2.addListener(() {
      _doCheckSubmitBtnEnable();
    });
    _controllerPwd3.addListener(() {
      _doCheckSubmitBtnEnable();
    });
  }

  @override
  void dispose() {
    _controllerPwd1.dispose();
    _controllerPwd2.dispose();
    _controllerPwd3.dispose();
    super.dispose();
  }

  void _doCheckSubmitBtnEnable() {
    String pwd1 = _controllerPwd1.text;
    String pwd2 = _controllerPwd2.text;
    String pwd3 = _controllerPwd3.text;
    if (pwd1 != null &&
        pwd1.length > 0 &&
        pwd2 != null &&
        pwd2.length > 0 &&
        pwd3 != null &&
        pwd3.length > 0) {
      setState(() {
        _submitBtnEnable = true;
      });
    } else {
      setState(() {
        _submitBtnEnable = false;
      });
    }
  }

  void doSubmit() {
    if (_controllerPwd1.text == null || _controllerPwd1.text.length < 1) {
      Fluttertoast.showToast(
        msg: "请输入原密码",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER
      );
      return;
    }
    if (_controllerPwd2.text == null || _controllerPwd2.text.length < 1) {
      Fluttertoast.showToast(
        msg: "请输入新密码",
        toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER
      );
      return;
    }
    if (_controllerPwd3.text == null || _controllerPwd3.text.length < 1) {
      Fluttertoast.showToast(
        msg: "请输入确认密码",
        toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER
      );
      return;
    }
//    RegExp reg = new RegExp(r"^[A-Za-z].*[0-9]|[0-9].*[A-Za-z]");
//    if (!reg.hasMatch(_controllerPwd2.text)) {
//      Fluttertoast.showToast(
//        msg: "新密码长度要大于8位，而且包含字母和数字",
//        toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER
//      );
//      return;
//    }
    if (_controllerPwd2.text.length > 20) {
      Fluttertoast.showToast(
        msg: "新密码长度不能大于20位",
        toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER
      );
      return;
    }
    if (_controllerPwd2.text != _controllerPwd3.text) {
      Fluttertoast.showToast(
        msg: "新密码两次输入不一致",
        toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER
      );
      return;
    }

    if(_controllerPwd1.text==_controllerPwd2.text){
      Fluttertoast.showToast(
        msg: "原密码和新密码一致",
        toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER
      );
      return;
    }

    doRequestResetPwdApi(_controllerPwd1.text, _controllerPwd2.text);
  }

  void doRequestResetPwdApi(oldPassword, newPassword) async {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: '正在提交...',
          );
        });

    try {
      _resetPwdApiStatus = ApiStatus(context);
      var resetPwdResponse =
          await _appApi.resetPassword(oldPassword, newPassword);
      _resetPwdApiStatus.apiSuccess(resetPwdResponse);
    } catch (onError) {
      _resetPwdApiStatus.apiError(onError);
    }
    Navigator.pop(context);
    if (_resetPwdApiStatus.isServiceSuccess()) {
      print("_resetPwdApiStatus, isServiceSuccess");
      doGoNextPage();
      return;
    }
    Fluttertoast.showToast(
        msg: _resetPwdApiStatus.getErrorMsg(), toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.CENTER);
  }

  void doGoNextPage() async {
//    Navigator.of(context).pop();

    SharedPreferences _preferences = Global.getPreferences();
    _preferences.clear();
    _preferences.commit();

    Global.cleanTokenAndNotifierRPC();
    Navigator.of(context).pushNamedAndRemoveUntil(PageName.passwordLogin, ModalRoute.withName('/'),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "修改登录密码",
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
        child: Container(
          width: 375,
          padding: EdgeInsets.only(left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 20,
                    width: 90,
                    margin: EdgeInsets.only(right: 20),
                    child: Text(
                      "输入原密码",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20)//限制长度
                      ],
                      controller: _controllerPwd1,
                      autofocus: true,
                      obscureText: true,
                      cursorColor: Color(0xFF333333),
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                      ),
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "请填写原密码",
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 1,
                color: Color(0xFFEBEBEB),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 20,
                    width: 90,
                    margin: EdgeInsets.only(right: 20),
                    child: Text(
                      "新密码",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20)//限制长度
                      ],
                      controller: _controllerPwd2,
                      autofocus: true,
                      obscureText: true,
                      cursorColor: Color(0xFF333333),
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                      ),
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "请输入新密码",
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 1,
                color: Color(0xFFEBEBEB),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 20,
                    width: 90,
                    margin: EdgeInsets.only(right: 20),
                    child: Text(
                      "确认密码",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20)//限制长度
                      ],
                      controller: _controllerPwd3,
                      autofocus: true,
                      cursorColor: Color(0xFF333333),
                      maxLines: 1,
                      obscureText: true,
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                      ),
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "请再次输入新密码",
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 1,
                color: Color(0xFFEBEBEB),
              ),
              Container(
                height: 48,
                width: 335,
                margin: EdgeInsets.only(top: 32),
                child: FlatButton(
                  onPressed: _submitBtnEnable ? doSubmit : null,
                  color: Color(0xFF2B61FF),
                  disabledColor: Color(0xFFCCCCCC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    "确定",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
