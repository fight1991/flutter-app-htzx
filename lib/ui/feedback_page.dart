import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("客服微信",style: TextStyle(fontWeight: FontWeight.w600),),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 40),
            child: Text(
              "客服微信号：gh_77cf35a4f248",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF2B61FF),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 352,
              width: 352,
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Image.asset(
                "assets/images/qrcode_wechat.jpg",
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
