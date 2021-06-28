import 'package:ydsd/common/index.dart';
import 'package:ydsd/http/base_response.dart';
import 'package:ydsd/http/entity/index.dart';
import 'package:ydsd/http/url_config.dart';
import 'package:ydsd/ui/index.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'app_api.g.dart';

@RestApi()
abstract class AppApi {
  static const String ApiName = "AppApi";
  factory AppApi() {
    return _AppApi(Global.dio,baseUrl:URL_Config.getUrl(AppApi.ApiName));
  }

  ///密码登录
  @POST("/merchant/operator/login")
  @FormUrlEncoded()
  Future<AppApiResponse<LoginResponse>> login(
      @Field("login_name") String login_name, //1:验证码登录2:密码登录
      @Field("password") String password,);

  ///获取用户信息
  @GET("/merchant/app/user_info")
  Future<AppApiResponse<UserInfo>> getUserinfo();


  ///修改用户密码
  @POST("/merchant/operator/update_pwd")
  @FormUrlEncoded()
  Future<AppApiResponse> resetPassword(
    @Field("old_password") String oldPassword,
    @Field("password") String newPassword,
  );
  ///取消订单
  @POST("/merchant/trade_order/cancel")
  @FormUrlEncoded()
  Future<AppApiResponse<String>> cancelOrder(
      @Field("trade_order_no") String trade_order_no
      );


  ///订单列表
  @POST("/merchant/trade_order/list")
  @FormUrlEncoded()
  Future<AppApiResponse<OrderListResponse>> getOrderList(
    @Field("page_no") String page_no,
    @Field("page_size") String page_size,
      {
        @Field("status") String status,
        @Field("keywords") String keywords,
      }

  );

  ///订单详情
  @POST("/merchant/trade_order/detail")
  @FormUrlEncoded()
  Future<AppApiResponse<OrderDetailResponse>> getOrderDetail(
      @Field("trade_order_no") trade_order_no
      );

  ///根据CID获取车辆信息
  ///data: 正常情况返回车牌号，有待支付订单的情况下 data返回订单号
  @POST("/merchant/acquiring/check")
  @FormUrlEncoded()
  Future<AppApiResponse<CidCarDetail>> getCarDetailByCid(
      @Field("cid") cid
      );


  ///商户确认收款
  @POST("/merchant/acquiring/submit")
  @FormUrlEncoded()
  Future<AppApiResponse<String>> submitAcquiring(
      @Field("cid") cid,
      @Field("total_amount") total_amount,
      @Field("device_code") device_code,
      {@Field("remark") remark}
      );


  ///退出登录
  @POST("/merchant/operator/logout")
  @FormUrlEncoded()
  Future<AppApiResponse> logout();


  ///App检查是否有新版本
  ///暂时(2020-05-20)后端只要求了app_name、app_os、build_num三个参数
  ///其他的参数App从一开始就要传，以便后期扩展
  /// 值递的值就是： 航天智行app_name=com.hangtian.hongtu/htzx     小蛮腰App=  com.hangtian.hongtu/ydsd
  @POST("/merchant/app/version")
  @FormUrlEncoded()
  Future<AppApiResponse<AppVersion>> checkAppUpdate({
    @Field("app_name") String appName, //App名称
    @Field("app_os") String appOs, //终端类型:Android、iOS
    @Field("build_num") String buildCode, //构建号:versionCode，build_no
    @Field("version") String version, //app的版本号versionName
    @Field("channel") String channel, //app的发布渠道
    @Field("userCheck") String userCheck, //是否用户手动点击检查更新
    @Field("brand") String brand, //手机厂商
    @Field("model") String model, //手机型号
    @Field("osVersion") String osVersion, //操作系统版本号
    @Field("romVersion") String romVersion = "", //Android上ROM的版本，MIUI11.0
    @Field("lang") String lang = "", //当前app的语言环境
    @Field("network") String network = "", //当前网络环境，mobile、Wi-Fi
    @Field("root") String root = "", //是否root：0=否、1=是
    @Field("mac") String mac = "", //网卡的Mac地址，可能为空
    @Field("deviceid") String deviceid = "", //Android：deviceid、iOS：广告ID，可能为空
  });

}
