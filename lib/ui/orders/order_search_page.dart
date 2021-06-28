import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/notifiers/index.dart';
import 'package:ydsd/ui/index.dart';
import 'package:ydsd/ui/widgets/load_more_widget.dart';

class OrderSearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderSearchState();
  }
}

class OrderSearchState extends State<OrderSearchPage> {
  ScrollController _scrollController = new ScrollController();
  TextEditingController _controllerSearch = TextEditingController();
  OrderListNotifier _notifier;
  FocusNode _contentFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerSearch.addListener(() {
        setState(() {
          print("=====?${_controllerSearch?.text}");
        });
      });
    });
    _notifier = OrderListNotifier(context, "全部");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Color(0xffF3F4F5),
        child: Column(
          children: <Widget>[
            buildBar(),
            Expanded(
              child: ChangeNotifierProvider(
                create:(context)=>_notifier,
                child: Consumer<OrderListNotifier>(
                  builder: (BuildContext context,OrderListNotifier notifier,Widget child){
                    return Stack(
                      children: <Widget>[buildList(), buildError()],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildError() {
    return Visibility(
        visible: showErrorPage(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: InkWell(
              onTap: () {
                reload();
              },
              child: Center(
                child: Text("暂无相关订单信息",
                    style: TextStyle(
                      color: Color(0xff999999),
                      fontSize: 14,
                    )),
              )),
        ));
  }

  void reload() {
    Toast.show("重新加载");
  }

  buildBar() {
    return Container(
      width: double.infinity,
      height: 80,
      padding: EdgeInsets.only(
        top: 24,
      ),
      color: Color(0xff2B61FF),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  searchOrder();
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "搜索",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),
                ),
              )),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              height: 40,
              margin: EdgeInsets.only(left: 52, right: 64),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 14, right: 12),
                    child: Image.asset(
                      "assets/images/search_gray.png",
                      width: 18,
                      height: 18,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  Expanded(
                    child: buildInputText(),
                  ),
                  Visibility(
                      visible: showSearchClear(),
                      child: InkWell(
                        onTap: () {
                          clearSearch();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          child: Image.asset(
                            "assets/images/search_clear.png",
                            width: 18,
                            height: 18,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  buildList() {
    return Visibility(
      visible: !showErrorPage(),
      child: Container(
        padding: EdgeInsets.only(top: 16),
        margin: EdgeInsets.only(left: 16,right: 16),
        child:MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _notifier.orderItems.length + 1,
            itemBuilder: (BuildContext context, int index) {
              return index >= _notifier.orderItems.length
                  ?  _buildLoadMore()
                  : _buildListItem(index);
            },
          ),
        ),

      ),
    );
  }

  buildInputText() {
    return TextField(
      focusNode: _contentFocusNode,
      autofocus: true,
      controller: _controllerSearch,
      cursorColor: Color(0xFF333333),
      maxLines: 1,
      style: TextStyle(
        color: Color(0xFF333333),
        fontSize: 16,
      ),
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        hintText: "请输入车牌号/订单号",
        labelStyle: TextStyle(color: Color(0xffCCCCCC)),
        hintStyle: TextStyle(
          color: Color(0xFFCCCCCC),
          fontSize: 16,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x00ffffff),
            width: 0,
          ),
        ),
        contentPadding: EdgeInsets.all(8),
      ),
    );
  }

  showSearchClear() {
    return _controllerSearch?.text != "";
  }

  void clearSearch() {
    _controllerSearch.clear();
  }

  showErrorPage() {
      if(_notifier==null|| _notifier.orderItems==null|| _notifier.orderItems.length==0){
        return true;
      }
      return false;
  }

  void searchOrder() {
    if(_controllerSearch.text==null||_controllerSearch.text==""){
      Toast.show("请输入车牌号或者订单号");
      return ;
    }
    _notifier.reloadList(keyword: _controllerSearch.text);
    _contentFocusNode.unfocus();
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
  isUnPay(int index) {
    return _notifier?.orderItems[index].status=="待支付";
  }
}
