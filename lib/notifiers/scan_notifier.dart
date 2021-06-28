import 'package:flutter/material.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/index.dart';

class ScanNotifier  {

  BuildContext _context;
  ///未绑定银行卡
  static int ERROR_UNBIND_BANK = 2045;
  ///未绑定app
  static int ERROR_UNBIND_APP = 2044;
  ///存在服务中订单
  static int ERROR_HAS_ORDER_INSERVICE = 2046;


  ScanNotifier(this._context);
  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse<CidCarDetail>> _getCarDetailStatus;

  CidCarDetail cidCarDetail;
  int errorCode = -1;
  String mCid;

  String errorMsg;
  Future<void> getCarDetailByCid(String cid) async {
    if(cid==null){
      return;
    }
//    cid="88828041774";
    mCid = cid;
    errorMsg = null;
    cidCarDetail = null;
    errorCode = -1;
    showDialog<bool>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            text: '加载中...',
          );
        });

    try {
        if(_getCarDetailStatus==null){
          _getCarDetailStatus = new  ApiStatus(this._context);
        }
        _getCarDetailStatus.reset();
        var response =  await _appApi.getCarDetailByCid(cid);
        _getCarDetailStatus.apiSuccess(response);
      } catch (onError) {
      _getCarDetailStatus.apiError(onError);
      }
    Navigator.pop(_context, true);
      if (_getCarDetailStatus.isServiceSuccess()) {
        cidCarDetail = _getCarDetailStatus.apiResponse?.data;
        errorCode = -1;
        errorMsg = _getCarDetailStatus.apiResponse?.msg;
//        notifyListeners();
        return;
      }

    cidCarDetail = _getCarDetailStatus.apiResponse?.data;
      errorCode = _getCarDetailStatus.apiResponse?.code;
    errorMsg = _getCarDetailStatus.apiResponse?.msg;
//      notifyListeners();
  }


}