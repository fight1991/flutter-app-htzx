import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/common/common_mixin.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatefulWidget {
  static const String ORDER_NO = "orderNo";
  String orderNo;

  @override
  State<StatefulWidget> createState() {
    return OrderDetailState();
  }
}

class OrderDetailState extends State<OrderDetailPage> with UtilWidgetMixin {
  OrderDetailNotifier _notify;

  @override
  void initState() {
    super.initState();
    _notify = OrderDetailNotifier(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      args = ModalRoute.of(context).settings.arguments;
      widget.orderNo = args[OrderDetailPage.ORDER_NO];
      print("=====>orderNo:${widget.orderNo}");
      _notify.loadOrderDetail(widget.orderNo);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _notify,
      child: Consumer<OrderDetailNotifier>(
        builder:
            (BuildContext context, OrderDetailNotifier notifier, Widget child) {
          return Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  Center(
                      child: Visibility(
                    visible: showCancelBtn(),
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Text(
                          "取消订单",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                      onTap: () {
                        cancelOrder(_notify.orderDetail);
                      },
                    ),
                  ))
                ],
                automaticallyImplyLeading: false,
                backgroundColor: getHeadColor(),
                centerTitle: false,
                title: Text(
                  "订单详情",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white),
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
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    );
                  },
                ),
              ),
              body:
                  notifier.netError ? _buildErrorWidget() : _buildBodyWidget());
        },
      ),
    );
  }

  isUnPayed() {
    return _notify.orderDetail?.status == "待支付";
  }

  isCanceled() {
    return _notify.orderDetail?.status == "已关闭";
  }

  Widget buildItemWidget(String title, String content) {
    return Container(
      margin: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
      ),
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xffEBEBEB), width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(color: Color(0xff666666), fontSize: 16),
          ),
          Text(
            content,
            style: TextStyle(color: Color(0xff333333), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyWidget() {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Container(
          color: getHeadColor(),
          padding: EdgeInsets.only(left: 23),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                child: Text(
                  _notify.orderDetail?.status ?? "",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(top: 24, bottom: 23),
              ),
              Visibility(
                visible: isUnPayed(),
                child: Padding(
                  child: Text(
                    _notify.orderDetail?.getYuan() ?? "",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  padding: EdgeInsets.only(top: 16, bottom: 8, right: 17),
                ),
              )
            ],
          ),
        ),
        buildItemWidget("车牌号", _notify.orderDetail?.plate_number ?? ""),
        buildItemWidget("交易金额", _notify.orderDetail?.getYuan() ?? ""),
        buildItemWidget("订单号", _notify.orderDetail?.trade_order_no ?? ""),
        buildItemWidget("创建时间", _notify.orderDetail?.getCreatTime() ?? ""),
        Visibility(
          visible: "已完成" == _notify.orderDetail?.status,
          child:
              buildItemWidget("交易时间", _notify.orderDetail?.getPayTime() ?? ""),
        ),
        Visibility(
          visible: "已关闭" == _notify.orderDetail?.status,
          child:
          buildItemWidget("取消时间", _notify.orderDetail?.getCloseTime() ?? ""),
        )
      ],
    ));
  }

  _buildErrorWidget() {
    return InkWell(
      onTap: () {
        _notify.loadOrderDetail(widget.orderNo);
      },
      child: Container(
        child: Center(
          child: Text("加载失败，点击重试"),
        ),
      ),
    );
  }

  void cancelOrder(OrderDetailResponse orderDetail) {
    showAlert(
        context: context,
        title: null,
        content: "您确定取消订单吗？",
        leftBtnText: "取消",
        rightBtnText: "确定",
        leftBtnCallback: (){
          Navigator.of(context).pop();
        },
        rightBtnCallback: () async {
          bool res = await _notify.cancelOrdel(orderDetail.trade_order_no);
          if(res){
            await _notify.loadOrderDetail(widget.orderNo);
            Navigator.of(context).pop();
          }

        });
  }

  showCancelBtn() {
    return _notify?.orderDetail?.status == "待支付";
  }

  getHeadColor() {
    return isCanceled()
        ? Color(0xff999999)
        : (isUnPayed() ? Color(0xffFE3824) : Color(0xff2B61FF));
  }
}
