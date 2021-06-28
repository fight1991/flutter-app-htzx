import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/order_item.dart';
import 'package:ydsd/notifiers/order_list_notifier.dart';
import 'package:ydsd/ui/index.dart';
import 'package:ydsd/ui/widgets/load_more_widget.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable


class OrderListsWidget extends StatefulWidget {
  static const  String TYPE_ALL = "全部";
  static const String TYPE_UN_PAYED = "待付款";

  String type = TYPE_ALL;
  OrderListsWidget(this.type);

  @override
  State<StatefulWidget> createState() {
   return OrderListState();
  }

}


class OrderListState extends State<OrderListsWidget> with AutomaticKeepAliveClientMixin{
  ScrollController _scrollController = new ScrollController();
  OrderListNotifier _notifier;
  OrderListState();
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _notifier = OrderListNotifier(context, widget.type);
    _scrollController.addListener(() {
      //触底刷新，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("addListener");
        if (_notifier.hasMorePage) {
          _notifier.loadMoreOrderList();
        }
      }
    });
    //默认刷新，第一次加载
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _notifier.loadMoreOrderList();
    });

  }

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider(
      create:(context)=>_notifier,
      child: Consumer<OrderListNotifier>(
        builder: (BuildContext context,OrderListNotifier notifier,Widget child){
          print("build widget orderCount:${_notifier?.orderItems?.length}");

          return  notifier.netError||notifier.noData()?
          _buildNetErrorWidget():
          _buildListWidget();
        },
      ),
    );


  }
  Widget _buildLoadMore() {
    return (_notifier.hasMorePage||_notifier.isLoading()) ?LoadMoreWidget():Center(child: Padding(padding: EdgeInsets.all(10,),child: Text("没有更多数据"),),);
  }
  Widget _buildListItem(int index) {
    var item = _notifier.orderItems[index];

    return Container(
      width: double.infinity,
      child:InkWell(
        child: Container(
          margin: EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.all(Radius.circular(4)),
//            border: Border(bottom: BorderSide(color: Color(0xffeeeeee),width: 0.5))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 16,top: 16,right: 12,bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildLabelWidget(index),
                            Padding(padding: EdgeInsets.only(left: 0),
                              child: Text(item?.plate_number,style: TextStyle(color: Color(0xff333333),fontSize: 16,fontWeight: FontWeight.bold)),)],),
                        Text(item?.getAmout()??"",style: TextStyle(color: isUnPay(index)?Color(0xffFE3824):Color(0xff333333),fontSize: 16,fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 13,bottom: 8),
                      child: Text("订单号：${item?.trade_order_no}",style: TextStyle(color: Color(0xff999999),fontSize: 12)),),
                    Text("创建时间：${item?.getCreateTime()}",style: TextStyle(color: Color(0xff999999),fontSize: 12)),

                  ],
                ),
              ),
              Visibility(
                visible: isUnPay(index),
                child: Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Color(0xffF3F4F5),
                ),
              ),

            ],
          ),
        ),
        onTap: (){
          Navigator.of(context).pushNamed(PageName.orderDetail,arguments: {OrderDetailPage.ORDER_NO:item.trade_order_no});
        },
      )
    );
  }

  Widget _buildErrorPage(){
    return Center(child: Text("暂无订单信息",style: TextStyle(color: Color(0xff999999),fontSize: 14),),);
  }
  isUnPay(int index) {
    return _notifier?.orderItems[index].status=="待支付";
  }

  @override
  bool get wantKeepAlive =>true;

 Widget _buildLabelWidget(int index) {
   String status = _notifier?.orderItems[index].status??"";
    return isUnPay(index)?
    Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.only(left: 4,right: 3,top: 2,bottom: 2),
      decoration: BoxDecoration(
          color: Color(0xffffffff),
          border:Border.all(width: 0.5,color: Color(0xffFE3824) ),
          borderRadius: BorderRadius.all(Radius.circular(2))
      ),
      child: Text(status,style: TextStyle(color: Color(0xffFE3824),fontSize: 10),),):
    Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.only(left: 4,right: 3,top: 2,bottom: 2),
      decoration: BoxDecoration(
          color: Color(0xffffffff),
          border:Border.all(width: 0.5,color: Color(0xff999999) ),
          borderRadius: BorderRadius.all(Radius.circular(2))
      ),
      child: Text(status,style: TextStyle(color: Color(0xff999999),fontSize: 10),),);
  }

  Widget _buildListWidget() {
   return Container(
     margin: EdgeInsets.only(left: 16,right: 16,top: 16),
     child: RefreshIndicator(
       child: ListView.builder(
         controller: _scrollController,
         itemCount: _notifier.orderItems.length + 1,
         physics: new AlwaysScrollableScrollPhysics(),
         itemBuilder: (BuildContext context, int index) {
           return index >= _notifier.orderItems.length
               ?  _buildLoadMore()
               : _buildListItem(index);
         },
       ),
       onRefresh: loadMore,
     ),
   );
  }

  Widget _buildNetErrorWidget() {
   return InkWell(
     onTap: (){
       setState(() {
         _notifier.loadMoreOrderList();
       });

     },
     child: Container(
       color: Colors.white,
       child: Center(child: Text("暂无订单信息",style: TextStyle(color: Color(0xffcccccc),fontSize: 14),),),
     ),
   );
  }

  String _doGetTimeLast(OrderItem item) {
   return item?.getCloseTime()??"--分--秒";
  }

  Future<void> loadMore() async {
    await _notifier.reloadList();
  }
}