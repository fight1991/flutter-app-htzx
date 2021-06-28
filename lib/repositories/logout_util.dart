import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/index.dart';

class LogOutUtil{
  static Future<bool> logout(BuildContext context)async{
    AppApi _appApi = AppApi();
    ApiStatus<AppApiResponse> _logOutStatus;

    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            text: '加载中...',
          );
        });


    try {
      if(_logOutStatus==null){
        _logOutStatus = new  ApiStatus(context);
      }
      _logOutStatus.reset();
      var response = await _appApi.logout();
      _logOutStatus.apiSuccess(response);
    } catch (onError) {
      _logOutStatus.apiError(onError);
    }
    Navigator.pop(context, true);
    return _logOutStatus.isServiceSuccess();

  }

}