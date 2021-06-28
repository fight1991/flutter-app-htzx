import 'package:dio/dio.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/url_config.dart';
import 'package:retrofit/retrofit.dart';
part 'app_update_api.g.dart';
@RestApi()
abstract class AppUpdateApi{
   static const String ApiName = "AppUpdateApi";

  factory AppUpdateApi() {return _AppUpdateApi(Global.dio,baseUrl:URL_Config.getUrl(AppUpdateApi.ApiName));}


}