import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:ydsd/http/utils/EitityFactory.dart';
import '../common/index.dart';
import '../http/index.dart';
import '../http/entity/index.dart';

class MockInterceptor implements InterceptorsWrapper {
  Map<String, Function> _functionMap = Map();

  MockInterceptor() {
//    _functionMap["/merchant/operator/login"] = _mockConfig;
//    _functionMap["/merchant/app/user_info"] = _mockConfig;
//    _functionMap["/merchant/trade_order/list"] = _mockConfig;
//    _functionMap["/merchant/trade_order/detail"] = _mockConfig;
//    _functionMap["/merchant/acquiring/check"] = _mockConfig;
//    _functionMap["/merchant/acquiring/submit"] = _mockConfig;
  }

  @override
  Future onRequest(RequestOptions options) async {
    print("------onRequest, path:${options.path}");
    if (_functionMap.containsKey(options.path)) {
      var data = await _functionMap[options.path](options);
      return Response(statusCode: 200, data: data, request: options);
    } else {
      return options;
    }
  }

  @override
  Future onResponse(Response response) async {
    return response;
  }

  @override
  Future onError(DioError err) async {
    return err;
  }

  AppApiResponse _ok({code = 200, msg = "OK", Object data}) {
    return AppApiResponse(code: code, msg: msg, data: data);
  }

  AppApiResponsePage _okp(
      {code = 200,
      msg = "OK",
      pageIndex = 1,
      pageSize = 20,
      count = 1000,
      List<dynamic> data}) {
    print("_okp, count:$count");
    return AppApiResponsePage(
        code: code,
        msg: msg,
        count: count,
        pageIndex: pageIndex,
        pageSize: pageSize,
        data: data);
  }

  dynamic _mockConfig(RequestOptions options) async {
    await Future.delayed(Duration(seconds: 1),(){});
    var response;
    switch(options.path){
      case "/merchant/acquiring/submit":
        int index  = Random().nextInt(3);
        switch (index){
//          case 1:
//            response = _ok(code:200,data:"ORDER_1009000");
//            break;
//          case 2:
//            response = _ok(code:2,msg:"您的余额不足",data:"ORDER_1009000");
//            break;
          default:

            response = _ok(code:1,data:"ORDER_1009000");
            break;
        }
        break;
      case "/merchant/acquiring/check":
        int index  = Random().nextInt(5);
        switch (index){
//          case 1:
//            response = _ok(code:1,data:"浙A89890");
//            break;
//          case 2:
//            response = _ok(code:2,data:"浙A89890");
//            break;
//          case 3:
//            response = _ok(code:3,data:"浙A89890");
//            break;
          default:
            response = _ok(code:200,data:"浙A89890");
            break;

        }
        break;
      case "/merchant/trade_order/detail":
        response = _ok( data:EntityFactory.genOrderDetail().toJson());
        break;
      case "/merchant/trade_order/list":
        response = _ok( data:EntityFactory.genOrderList().toJson());
        break;
      case "/merchant/operator/login":
        print("===mockLogin====");
        response = _ok(data: LoginResponse(login_name: "快乐悍马",
            mobile: "15157117196",
            nick_name: "hanm",
            real_name: "liialei",status: "状态1",telephone: "1554542545",token: "token:1225555dadasd",token_expired: 112).toJson());
        break;
      case "/merchant/app/user_info":
        response = _ok(data: UserInfo(
            login_name: "快乐悍马",
            org_name: "深证创新科技航天研究院，杭州滨江区长河街道分院，神经空间堂口",
            real_name: "李小雷",
          mobile: "15157117196",
          nick_name: "hanm",status: "状态1",telephone: "1554542545").toJson());
        break;
    }
    if(response!=null){
      return response.toJson();
    }else{
      return null;
    }

  }
}
