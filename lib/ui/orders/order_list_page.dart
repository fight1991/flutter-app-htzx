import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/channel/index.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/ui/index.dart';

import '../../common/global.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  TabController mController;

  @override
  void initState() {
    super.initState();
    mController = new TabController(length: 2, vsync: this);
    mController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Center(
              child: InkWell(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
                    child: Image.asset(
                      "assets/images/search.png",
                      width: 18,
                      height: 18,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                onTap: () {
                  searchOrder();
                },
          ))
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "订单管理",
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
        bottom: TabBar(
            controller: mController,
            tabs: <Widget>[
              Tab(text: "待支付"),
              Tab(text: "全部"),
            ],
            indicatorColor: Colors.white),
      ),
      body: Container(
          child: TabBarView(
        controller: mController,
        children: <Widget>[
          OrderListsWidget(OrderListsWidget.TYPE_UN_PAYED),
          OrderListsWidget(OrderListsWidget.TYPE_ALL),
        ],
      )),
      backgroundColor: Color(0xfff3f4f5),
    );
  }

  void searchOrder() {
    Toast.show("搜索订单");
    Navigator.of(context).pushNamed(PageName.orderSearch);
  }
}
