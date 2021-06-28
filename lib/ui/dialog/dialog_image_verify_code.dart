import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/channel/app_method_channel.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:provider/provider.dart';

class ImageVerifyCodeDialog extends Dialog {
  String mobile;
  int _time;

  TextEditingController _controller = TextEditingController();

  ImageVerifyCodeDialog({Key key, @required this.mobile}) : super(key: key);

  String get requestUrl {
    int now = DateTime.now().millisecondsSinceEpoch;
    int _t = _time != null ? _time : now;
    String _path = "/eplate/merchant/operator/gen_image_code";
    String baseUrl = Global.isRelease?Constant.rpcBaseUrlRelease:Constant.rpcBaseUrlTest;
    String _url = "${baseUrl}$_path?mobile=${mobile}&t=${_t}";
    return _url;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, //透明类型
      child: Center(
        child: SizedBox(
          width: 375.0 * 0.8,
          child: Container(
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 40),
                  alignment: Alignment.center,
                  child: Text(
                    '请输入图形验证码',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ChangeNotifierProvider(
                          create: (context) {
                            return VerifyCodeChangeNotifier();
                          },
                          child: Consumer<VerifyCodeChangeNotifier>(
                            builder: (context, value, child) {
                              return InkWell(
                                onTap: () {
                                  value.update();
                                  } ,
                                child: Container(
                                  height: 80,
                                  width: 100,
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    requestUrl,
                                    fit: BoxFit.scaleDown,
                                    headers: {
                                      Constant.rpcAuthenticationKey:
                                          Global.isRelease?Constant.rpcAuthenticationAppCodeRelease:Constant.rpcAuthenticationAppCodeTest,
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 200,
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            cursorColor: Color(0xFF333333),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF000000),
                            ),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "请输入图片的内容",
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFEBEBEB),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFEBEBEB),
                                  width: 1.0,
                                ),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFEBEBEB),
                                  width: 1.0,
                                ),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFEBEBEB),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 40,
                      width: 124,
                      margin: EdgeInsets.only(top: 32),
                      child: OutlineButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: Color.fromARGB(255, 43, 98, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          "取消",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, width: 16),
                    Container(
                      height: 40,
                      width: 124,
                      margin: EdgeInsets.only(top: 32),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(_controller.text);
                          AppMethodChannel.onUmEvent("P050000");
                        },
                        color: Color.fromARGB(255, 43, 98, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          "确定",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
