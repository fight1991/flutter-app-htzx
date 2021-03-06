
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/repositories/repo_order_detail.dart';
import 'package:ydsd/ui/index.dart';
import 'package:provider/provider.dart';

class CollectionWaittingPage extends StatefulWidget{
  static const String ORDER_NO = "order_no";
  static const String TOTAL_AMOUNT = "total_amount";
  String orderNo;
  String total_amount;

    bool widgetInFront = false;
  @override
  State<StatefulWidget> createState() {
    return CollectionWaittingState();
  }

}
class CollectionWaittingState extends State<CollectionWaittingPage> with WidgetsBindingObserver{
  var args;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments;
    print("didChangeDependencies=====");
    widget.orderNo = args[CollectionWaittingPage.ORDER_NO];
    widget.total_amount = args[CollectionWaittingPage.TOTAL_AMOUNT];
    print("orderNo=${widget.orderNo},total_amount=${widget.orderNo}");
  }

  void dispose(){
    super.dispose();
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  Timer timer;
  RepoOrderDetail _repoOrderDetail;
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repoOrderDetail = RepoOrderDetail();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.widgetInFront = true;
      timer = Timer.periodic(Duration(seconds: 5), (timer)  {
        print("widget.widgetInFront=${widget.widgetInFront},result = ${widget.widgetInFront==true}");
        if(widget.widgetInFront==true){
          _doLoadOrderDetail();
        }

      });
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("didChangeAppLifecycleState ${state.toString()}");
    if (state == AppLifecycleState.paused) {
      //??????????????????
      print("MyHomePage Background");
      widget.widgetInFront = false;
    }
    if (state == AppLifecycleState.resumed) {
      //??????????????????
      print("MyHomePage  Foreground");
      widget.widgetInFront = true;
    }

  }

  void showOrderDetail(OrderDetailResponse orderDetail) {
    print("=======tset=======");
    if("?????????"==orderDetail?.status){
      _buildOrderCancledDialog();
      timer?.cancel();
    }else if("?????????"==orderDetail?.status){
      widget.widgetInFront = false;
      print("=======tset=======to collectionSuccess");
      Navigator.of(context).pushNamed(PageName.collectionSuccess,
          arguments: {CollectionSuccessPage.ORDER_NO:widget.orderNo,
            CollectionSuccessPage.TOTAL_AMOUNT:widget.total_amount,
          }
      ).then((value) => Navigator.of(context).pop());
      timer?.cancel();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff2B61FF),
          centerTitle: false,
          title: Text(
            "????????????",
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
                "assets/images/money_waitting.png",
                height: 40,
                width: 40,
                fit: BoxFit.scaleDown,
              ),
              Padding(padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "????????????",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff333333),fontSize: 18),
                  )
              ),
              //????????????5s???????????????,

              Padding(padding: EdgeInsets.only(top: 16),
                child:  RichText(
                  text: TextSpan(
                      text: "??????????????????????????????????????????",
                      style: TextStyle(color: Color(0xff666666),fontSize: 14),
                      children: [
                      ]),
                  textDirection: TextDirection.ltr,
                ),
              ),
              Container(margin: EdgeInsets.only(top: 24),
                  child:   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 112,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              border: Border.all(color: Color(0xffCCCCCC),width: 0.5)
                          ),
                          child:  FlatButton(
                            onPressed: (){_doLoadOrderDetail();},
                            child: Text("??????",style: TextStyle(color: Color(0xff333333),fontSize: 16),),)
                      ),
                      Container(width: 24,),
                      Container(
                          width: 120,
                          height: 34,
                          decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              border: Border.all(color: Color(0xffCCCCCC),width: 0.5)
                          ),
                          child:  FlatButton(
                            onPressed: (){
                              widget.widgetInFront = false;
                              Navigator.of(context).pushNamed(PageName.orderDetail,arguments: {OrderDetailPage.ORDER_NO:widget.orderNo}).then((value){
                                widget.widgetInFront = true;
                              });},
                            child: Text("????????????",style: TextStyle(color: Color(0xff333333),fontSize: 16),),)
                      )


                    ],
                  )
              ),
            ],
          ),
        )
    );
  }

  void _buildOrderCancledDialog() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog.simple(
          contentText: "???????????????",
          leftBtnText: null,
          leftBtnCallback:null,
          rightBtnText: "??????",
          rightBtnCallback: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );

      },
    );
  }

  void _doLoadOrderDetail() async{
    var orderDetail = await _repoOrderDetail?.loadOrderDetail(widget.orderNo,context);
    showOrderDetail(orderDetail);
  }



}

