
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/ui/index.dart';

class CollectionErrorPage extends StatefulWidget{
  static const String ORDER_NO = "order_no";
  static const String ERROR_MSG = "error_msg";

  String orderNo;
  String errorMsg;
  @override
  State<StatefulWidget> createState() {
    return CollectionErrorState();
  }

}
class CollectionErrorState extends State<CollectionErrorPage>{
  var args;
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments;
    print("didChangeDependencies=====");
    widget.orderNo = args[CollectionErrorPage.ORDER_NO];
    widget.errorMsg = args[CollectionErrorPage.ERROR_MSG];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "扣款失败",
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
              "assets/images/money_error.png",
              height: 40,
              width: 40,
              fit: BoxFit.scaleDown,
            ),
            Padding(padding: EdgeInsets.only(top: 16),
                child: Text(
                  "扣款失败",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff333333),fontSize: 18),
                )
            ),
            //页面将在5s后返回首页,

            Visibility(
              child: Padding(padding: EdgeInsets.only(top: 16),
                child:  RichText(
                  text: TextSpan(
                      text: "失败原因：${widget.errorMsg??"--"}",
                      style: TextStyle(color: Color(0xffFE3824),fontSize: 14),
                      children: [
                      ]),
                  textDirection: TextDirection.ltr,
                ),
            ),
            visible: false,),
            Container(margin: EdgeInsets.only(top: 24),
              child:   Container(
                width: 112,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Color(0xffCCCCCC),width: 0.5)
                ),
                child:  FlatButton(
                  onPressed: (){Navigator.of(context).pushNamed(PageName.orderDetail,arguments: {OrderDetailPage.ORDER_NO:widget.orderNo});},
                  child: Text("查看订单",style: TextStyle(color: Color(0xff333333),fontSize: 16),),)
              )
            ),
          ],
        ),
      )
    );
  }



}

