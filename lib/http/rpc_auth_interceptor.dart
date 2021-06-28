import 'package:dio/dio.dart';
import 'package:ydsd/channel/app_method_channel.dart';
import 'package:ydsd/common/constant.dart';
import 'package:ydsd/common/global.dart';

class RpcAuthInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options) async {
    String deviceId = await AppMethodChannel.getHtDeviceId();
    print("deviceId:"+deviceId);
    options.headers.putIfAbsent(Constant.rpcDeviceIdKey,()=>deviceId);
    options.headers.putIfAbsent(
        Constant.rpcClientTimeKey, () => DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future onError(DioError err) async {
    var statusCode = err?.response?.statusCode;
    print("onError rpc_auth_code:$statusCode");
    if (statusCode == 401) {
      Global.doLogout();
      return;
    }
  }

  @override
  Future onResponse(Response response) async {
    if (response.data is String) {
    } else if (response.data is Map) {
      Map map = response.data as Map;
      print("onResponse rpc_auth_code:${map['code']}");
      if (map['code'] == 401) {
        Global.doLogout();
      }
    }
  }
}
