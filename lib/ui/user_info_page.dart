
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/repositories/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'index.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F4F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "用户信息",
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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
           Column(
             children: <Widget>[
               Container(
                 padding: EdgeInsets.only( left: 24),
                 color: Colors.white,
                 child:Container(
                   padding: EdgeInsets.only(right:29,top: 13,bottom: 13),
                   decoration: BoxDecoration(
                       color: Colors.white,
                       border:Border(bottom: BorderSide(color: Color(0xffeeeeee),width: 0.5))
                   ),
                   child:  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: <Widget>[
                       Padding(padding: EdgeInsets.only( top: 16,bottom: 16),
                         child: Text(
                           "头像",
                           style: TextStyle(
                               color: Color(0xff666666),
                               fontSize: 16),
                         ),),
                       Image.asset(
                         "assets/images/head_img_def.png",
                         height: 40,
                         width: 40,
                         fit: BoxFit.scaleDown,
                       ),
                     ],
                   ),
                 ),
               ),
               buildItem("商铺名",Global.profile?.user?.org_name??""),
               buildItem("用户名",Global.profile?.user?.login_name??""),
               Container(height: 8,),
               buildItemClickAble("修改登录密码",(){
                 Navigator.of(context).pushNamed(PageName.changePassword);
               }),
             ],
           ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: (){_doShowLogoutDialog(context);},
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
//                    color: Colors.white,
                      border:Border(bottom: BorderSide(color: Color(0xffeeeeee),width: 0.5))
                  ),
                  child:Center(
                    child: Padding(padding: EdgeInsets.only( top: 16,bottom: 16),
                        child:Text(
                          "退出当前账号",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 16),
                        )),
                  )

                  ,),
              )
            )

    ],
        ),
      ),
    );
  }


  Widget buildItem(String title, String title2) {
    return  Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.only(right:29,left: 24),
        decoration: BoxDecoration(
//                color: Colors.white,
            border:Border(bottom: BorderSide(color: Color(0xffeeeeee),width: 0.5))
        ),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(padding: EdgeInsets.only( top: 16,bottom: 16),
              child: Text(
                title,
                style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 16),
              ),),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title2??"",
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16),
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  Widget buildItemClickAble(String title,  Function() click) {
    return  Material(
      color: Colors.white,
      child: InkWell(
        child: Container(
          padding: EdgeInsets.only(right:29,left: 24),
          decoration: BoxDecoration(
//                color: Colors.white,
              border:Border(bottom: BorderSide(color: Color(0xffeeeeee),width: 0.5))
          ),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(padding: EdgeInsets.only( top: 16,bottom: 16),
                child: Text(
                  title,
                  style: TextStyle(
                      color: Color(0xff666666),
                      fontSize: 16),
                ),),
              Visibility(
                visible: click!=null,
                child: Image.asset(
                  "assets/images/select_right.png",
                  height: 16,
                  width: 16,
                  fit: BoxFit.scaleDown,
                ),
              )
            ],
          ),
        ),
        onTap: click,
      ),
    );
  }
  void _doShowLogoutDialog(context) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog.simple(
          contentText: "确定要退出吗？",
          leftBtnCallback: () {
            Navigator.of(context).pop();
          },
          rightBtnCallback: () {
            _doLogout(context);
            //Navigator.of(context).pop();
          },
        );
      },
    );
  }

  String doFetchParam(String paramName) {
    var resultStr;
      SharedPreferences _prefs = Global.getPreferences();
      resultStr = _prefs.getString(paramName);
    return resultStr;
  }

  void doSaveLoginName(String loginName) {
      SharedPreferences _prefs = Global.getPreferences();
      _prefs.setString(Constant.spKeyUserPhone, loginName);
  }

  void _doLogout(BuildContext context) async{
    final _mobile = doFetchParam(Constant.spKeyUserPhone);
    SharedPreferences _preferences = Global.getPreferences();
    _preferences.clear();
    _preferences.commit();
    // 重新保存用户名 通过地址栏传递build会清空，兼容token失效等情景跳回登录页获取用户名
    doSaveLoginName(_mobile);
    Global.cleanTokenAndNotifierRPC();

    bool res = await LogOutUtil.logout(context);

    Navigator.of(context).pushNamedAndRemoveUntil(
      PageName.passwordLogin,
      ModalRoute.withName('/'),
    );
  }
}
