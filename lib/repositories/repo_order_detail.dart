import 'package:flutter/material.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/index.dart';

class RepoOrderDetail{

  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<OrderDetailResponse>> _orderDetailStatus;
  Future<OrderDetailResponse> loadOrderDetail(String orderNo,BuildContext _context) async {
    if(orderNo==null){
      return null;
    }
    try {
      showDialog<bool>(
          context: _context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingDialog(
              text: '加载中...',
            );
          });

      if(_orderDetailStatus==null){
        _orderDetailStatus = new  ApiStatus(_context);
      }
      _orderDetailStatus.reset();
      var loginResponse = await _appApi.getOrderDetail(orderNo);
      _orderDetailStatus.apiSuccess(loginResponse);
    } catch (onError) {
      _orderDetailStatus.apiError(onError);
    }
    Navigator.pop(_context, true);
    if (_orderDetailStatus.isServiceSuccess()) {
      return _orderDetailStatus.apiResponse.data;

    }
    Toast.show(_orderDetailStatus.apiResponse.msg);
    return null;
  }

}