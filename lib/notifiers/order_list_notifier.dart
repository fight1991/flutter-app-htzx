import 'package:flutter/material.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/index.dart';

class OrderListNotifier extends ChangeNotifier{

  BuildContext _context;
  int _pageNo = 0;
  int _pageSize = 10;
  String _status;
  String keyWords;


  OrderListNotifier(this._context,this._status);
  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<OrderListResponse>> _orderListStatus;

  bool hasMorePage = true;
  bool netError = false;
  List<OrderItem> orderItems=[];

  Future<void> loadMoreOrderList() async {
    await _loadOrderList(this._pageNo, this._pageSize, this._status);
  }
  Future<void>  reloadList({String keyword}) async {
    _pageNo=0;
    orderItems.clear();
    keyWords = keyword;
    await loadMoreOrderList();
  }

  Future<void> _loadOrderList(int page_no,int page_size,String paramstatus,) async {
    print("loadOrderLIst...pageNo:$page_no");
    netError = false;
    try {
        if(_orderListStatus==null){
          _orderListStatus = new  ApiStatus(this._context);
        }
        _orderListStatus.reset();
        var loginResponse;
        var status;
        if(OrderListsWidget.TYPE_UN_PAYED==paramstatus){
          status= "待支付";
        }else{
          status= "";//待支付,已完成,已关闭
        }
        print("getOrderList 参数： page_no:${page_no.toString()},pageSize:${page_size.toString()},status:$status,keywords:$keyWords");
        loginResponse = await _appApi.getOrderList(page_no.toString(), page_size.toString(),status: status,keywords: keyWords);
        _orderListStatus.apiSuccess(loginResponse);
      } catch (onError) {
        _orderListStatus.apiError(onError);
      }
      if (_orderListStatus.isServiceSuccess()) {
        print("getOrderList success,orderItemCount:${_orderListStatus.apiResponse?.data?.list}");
        print("getOrderList success,data.pageNo:${_orderListStatus.apiResponse?.data?.page_no}");
        if(_orderListStatus.apiResponse?.data?.list!=null){
          orderItems.addAll(_orderListStatus.apiResponse.data.list);
          _pageNo=_orderListStatus.apiResponse.data.page_no+1;
        }
        hasMorePage = orderItems.length<_orderListStatus.apiResponse.data.total_count;
        print("hasMorePage:$hasMorePage");
        notifyListeners();
        return;
      }
      Toast.show(_orderListStatus.getErrorMsg());
      hasMorePage = orderItems.length<_orderListStatus.apiResponse.data.total_count;
      print("hasMorePage:$hasMorePage");
      netError=true;
      notifyListeners();
  }

  void timeCheck() {
     for(var element in orderItems){
       //是否存在超时东莞诺丹，若存在，刷新数据
       if(element.isTimeOut()){
         reloadList();
         break;
       }

       //是否存在待支付的订单，若存在，刷新页面
       if(element.status=="待支付"){
         notifyListeners();
         break;
       }
     }
  }

  bool noData() {
    if(_orderListStatus!=null&&!_orderListStatus.isLoading()&&orderItems.length==0){
      return true;
    }
    return false;
  }

  bool isLoading() {
    return _orderListStatus!=null&&_orderListStatus.isLoading();
  }


}