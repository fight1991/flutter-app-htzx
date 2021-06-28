import 'package:dio/dio.dart';
import 'package:ydsd/channel/app_method_channel.dart';
import 'package:ydsd/common/constant.dart';
import 'package:ydsd/common/global.dart';
import 'package:intl/intl.dart';

class RpcTimeInterceptor extends Interceptor {
  static int _server_utc_time = DateTime.now().millisecondsSinceEpoch;
  static int _local_utc_time = DateTime.now().millisecondsSinceEpoch;

  DateFormat formate = new DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'","en_US");
  @override
  Future onRequest(RequestOptions options) async {

  }

  @override
  Future onError(DioError err) async {

  }

  @override
  Future onResponse(Response response) async {
     try{
       if(response!=null&&response.headers!=null&&response.headers["Date"]!=null){
         String date = response.headers["Date"][0];
         _local_utc_time =DateTime.now().millisecondsSinceEpoch;
         _server_utc_time = formate.parseUTC(date).millisecondsSinceEpoch;
       }
     }catch(e){

     }
  }

  static int getServerUTCTime(){
    return _server_utc_time+DateTime.now().millisecondsSinceEpoch-_local_utc_time;
  }
}
