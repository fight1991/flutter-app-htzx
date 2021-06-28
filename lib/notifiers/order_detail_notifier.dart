import 'package:flutter/material.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/index.dart';

class OrderDetailNotifier extends ChangeNotifier{

  BuildContext _context;
  bool netError = false;
  OrderDetailNotifier(this._context);
  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<OrderDetailResponse>> _orderDetailStatus;
  ApiStatus<AppApiResponse<String>> _cancelOrderStatus;
  OrderDetailResponse orderDetail;

  ///取消订单
  Future<bool> cancelOrdel(String trade_order_no)async {
    if(trade_order_no==null){
      return false;
    }
    showDialog<bool>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            text: '取消中...',
          );
        });
    try {
      if(_cancelOrderStatus==null){
        _cancelOrderStatus = new  ApiStatus(this._context);
      }
      _cancelOrderStatus.reset();
      var calRes = await _appApi.cancelOrder(trade_order_no);
      _cancelOrderStatus.apiSuccess(calRes);
    } catch (onError) {
      _cancelOrderStatus.apiError(onError);
    }
    Navigator.pop(_context, true);
    if (_cancelOrderStatus.isServiceSuccess()) {

      return true;
    }else{
       return false;
    }
  }
  Future<void> loadOrderDetail(String orderNo) async {
    if(orderNo==null){
      return;
    }
    showDialog<bool>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            text: '加载中...',
          );
        });

    netError = false;
    try {
        if(_orderDetailStatus==null){
          _orderDetailStatus = new  ApiStatus(this._context);
        }
        _orderDetailStatus.reset();
        var loginResponse = await _appApi.getOrderDetail(orderNo);
        _orderDetailStatus.apiSuccess(loginResponse);
      } catch (onError) {
        _orderDetailStatus.apiError(onError);
      }
    Navigator.pop(_context, true);
      if (_orderDetailStatus.isServiceSuccess()) {
        orderDetail = _orderDetailStatus.apiResponse.data;

      }else{
        netError = true;
      }

      notifyListeners();
  }

  bool timeCheck() {
    if(_orderDetailStatus!=null&&!_orderDetailStatus.isLoading()&& "待支付"==orderDetail?.status&&RpcTimeInterceptor.getServerUTCTime()/1000>=orderDetail?.valid_date){
        print("==============");
      return true;
    }

    if("待支付"==orderDetail?.status){
      notifyListeners();
    }
    return false;
  }





}