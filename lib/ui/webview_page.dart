import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  static final String argNameUrl = "arg_name_url";
  static final String argNameTitle = "arg_name_title";
  static final String defaultTitle = "小蛮腰";

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  var _arguments;
  String _title = "";
  String _url = "";

  WebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> doRequestPop() async {
    print("doRequestPop");
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context).settings.arguments;
    _title = _arguments[WebViewPage.argNameTitle];
    _title ??= WebViewPage.defaultTitle;
    _url = _arguments[WebViewPage.argNameUrl];

    return WillPopScope(
      onWillPop: doRequestPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text("$_title",style: TextStyle(fontWeight: FontWeight.w600),),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Image.asset(
                  "assets/images/toolbar_back.png",
                  width: 16,
                  height: 19,
                  fit: BoxFit.scaleDown,
                ),
                onPressed: () async {
                  if (await _controller.canGoBack()) {
                    await _controller.goBack();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              );
            },
          ),
        ),
        body: WebView(
          initialUrl: "$_url",
          //JS执行模式 是否允许JS执行
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onPageStarted: (url) {
            print("onPageStarted:$url");
          },
          onPageFinished: (url) {
            print("onPageFinished:$url");
            _controller.evaluateJavascript("document.title").then((result) {
              setState(() {
                _title = result;
              });
            });
          },

          navigationDelegate: (NavigationRequest request) {
            print("navigationDelegate:${request.url}");
            if (request.url.startsWith("myapp://")) {
              print("即将打开 ${request.url}");

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          javascriptChannels: <JavascriptChannel>[
            JavascriptChannel(
                name: "share",
                onMessageReceived: (JavascriptMessage message) {
                  print("参数： ${message.message}");
                }),
          ].toSet(),
        ),
      ),
    );
  }
}
