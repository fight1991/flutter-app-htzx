
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CollectionSuccessPage extends StatefulWidget{
  static const String ORDER_NO = "order_no";
  static const String TOTAL_AMOUNT = "total_amount";

  String total_amount;
  String orderNo;
  @override
  State<StatefulWidget> createState() {
    return CollectionSuccessState();
  }

}
class CollectionSuccessState extends State<CollectionSuccessPage>{
  Timer timer;
  int lastSeconds = 5;
  var args;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments;
    print("didChangeDependencies=====");
    widget.total_amount = args[CollectionSuccessPage.TOTAL_AMOUNT];
    widget.orderNo = args[CollectionSuccessPage.ORDER_NO];
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {


      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if(lastSeconds<=0){
            Navigator.of(context).pop();
            return;
          }
          if(lastSeconds>0){
            lastSeconds--;
          }
        });
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "扣款成功",
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
        width: double.infinity,
        margin: EdgeInsets.only(top: 80),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/money_success.png",
                height: 40,
                width: 40,
                fit: BoxFit.scaleDown,
              ),
              Padding(padding: EdgeInsets.only(top: 16),
                child: Text(
                  "扣款成功",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff333333),fontSize: 18),
                )
              ),
              //页面将在5s后返回首页,
              Padding(padding: EdgeInsets.only(top: 16),
                  child:  RichText(
                    text: TextSpan(
                        text: "交易金额： ",
                        style: TextStyle(color: Color(0xff333333),fontSize: 14),
                        children: [
                          TextSpan(
                              text: _getAmountYuan(), style: TextStyle(color: Color(0xffFE3824))),
                        ]),
                    textDirection: TextDirection.ltr,
                  ),
              ),
              Padding(padding: EdgeInsets.only(top: 24),
                  child:  RichText(
                    text: TextSpan(
                        text: "页面将在",
                        style: TextStyle(color: Color(0xff999999),fontSize: 14),
                        children: [
                          TextSpan(
                              text: "${lastSeconds}s", style: TextStyle(color: Color(0xff2B61FF))),
                          TextSpan(
                              text: "后返回首页", style: TextStyle(color: Color(0xff999999))),

                        ]),
                    textDirection: TextDirection.ltr,
                  ),
              ),
            ],
        ),
      )
    );
  }

  String _getAmountYuan() {
    if(widget.total_amount!=null)
      return "￥${widget.total_amount}";
    return " ";
  }



}

