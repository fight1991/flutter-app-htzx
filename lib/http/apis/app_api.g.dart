// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _AppApi implements AppApi {
  _AppApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final Dio _dio;

  String baseUrl;

  @override
  login(login_name, password) async {
    ArgumentError.checkNotNull(login_name, 'login_name');
    ArgumentError.checkNotNull(password, 'password');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'login_name': login_name, 'password': password};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/operator/login',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<LoginResponse>.fromJson(_result.data);
    return value;
  }

  @override
  getUserinfo() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/app/user_info',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<UserInfo>.fromJson(_result.data);
    return value;
  }

  @override
  resetPassword(oldPassword, newPassword) async {
    ArgumentError.checkNotNull(oldPassword, 'oldPassword');
    ArgumentError.checkNotNull(newPassword, 'newPassword');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'old_password': oldPassword, 'password': newPassword};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/operator/update_pwd',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<dynamic>.fromJson(_result.data);
    return value;
  }

  @override
  cancelOrder(trade_order_no) async {
    ArgumentError.checkNotNull(trade_order_no, 'trade_order_no');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'trade_order_no': trade_order_no};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/trade_order/cancel',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<String>.fromJson(_result.data);
    return value;
  }

  @override
  getOrderList(page_no, page_size, {status, keywords}) async {
    ArgumentError.checkNotNull(page_no, 'page_no');
    ArgumentError.checkNotNull(page_size, 'page_size');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _data = {
      'page_no': page_no,
      'page_size': page_size,
      'status': status,
      'keywords': keywords
    };
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/trade_order/list',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<OrderListResponse>.fromJson(_result.data);
    return value;
  }

  @override
  getOrderDetail(trade_order_no) async {
    ArgumentError.checkNotNull(trade_order_no, 'trade_order_no');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'trade_order_no': trade_order_no};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/trade_order/detail',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<OrderDetailResponse>.fromJson(_result.data);
    return value;
  }

  @override
  getCarDetailByCid(cid) async {
    ArgumentError.checkNotNull(cid, 'cid');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'cid': cid};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/acquiring/check',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<CidCarDetail>.fromJson(_result.data);
    return value;
  }

  @override
  submitAcquiring(cid, total_amount, device_code, {remark}) async {
    ArgumentError.checkNotNull(cid, 'cid');
    ArgumentError.checkNotNull(total_amount, 'total_amount');
    ArgumentError.checkNotNull(device_code, 'device_code');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _data = {
      'cid': cid,
      'total_amount': total_amount,
      'device_code': device_code,
      'remark': remark
    };
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/acquiring/submit',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<String>.fromJson(_result.data);
    return value;
  }

  @override
  logout() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/operator/logout',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<dynamic>.fromJson(_result.data);
    return value;
  }

  @override
  checkAppUpdate(
      {appName,
      appOs,
      buildCode,
      version,
      channel,
      userCheck,
      brand,
      model,
      osVersion,
      romVersion = "",
      lang = "",
      network = "",
      root = "",
      mac = "",
      deviceid = ""}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _data = {
      'app_name': appName,
      'app_os': appOs,
      'build_num': buildCode,
      'version': version,
      'channel': channel,
      'userCheck': userCheck,
      'brand': brand,
      'model': model,
      'osVersion': osVersion,
      'romVersion': romVersion,
      'lang': lang,
      'network': network,
      'root': root,
      'mac': mac,
      'deviceid': deviceid
    };
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/merchant/app/version',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = AppApiResponse<AppVersion>.fromJson(_result.data);
    return value;
  }
}
