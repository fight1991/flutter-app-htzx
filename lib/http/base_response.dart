import 'entity/index.dart';
import 'entity_json_convert.dart';

class ApiResponse {
  bool isServiceSuccess() {
    return false;
  }
}

class ApiResponsePage extends ApiResponse {
  bool isEmpty() {
    return true;
  }

  int dataSize() {
    return 0;
  }
}

class AppApiResponse<T> extends ApiResponse {
  String msg;
  int code;
  T data;

  AppApiResponse({this.code, this.msg, this.data});

  bool isServiceSuccess() {
    return 200 == code;
  }

  factory AppApiResponse.fromJson(Map<String, dynamic> json) {
    return AppApiResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: AppApiJsonConvert.convert(json['data'], T),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': this.msg,
      'code': this.code,
      'data': this.data,
    };
  }
}

class AppApiResponsePage<T> extends ApiResponsePage {
  String msg;
  int code;
  List<T> data;
  int pageIndex;
  int pageSize;
  int count;

  AppApiResponsePage({
    this.code,
    this.msg,
    this.data,
    this.pageIndex,
    this.pageSize,
    this.count,
  });

  bool isServiceSuccess() {
    return 200 == code;
  }

  bool isEmpty() {
    return data == null || data.length < 1;
  }

  int dataSize() {
    return data != null ? data.length : 0;
  }

  factory AppApiResponsePage.fromJson(Map<String, dynamic> json) {
    var jsondata = json['data'];
    var data = jsondata == null ? null : jsondata["list"];
    var pageIndex = jsondata == null ? null : jsondata["page_no"];
    var pageSize = jsondata == null ? null : jsondata["page_size"];
    var count = jsondata == null ? null : jsondata["total_count"];
    return AppApiResponsePage(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: AppApiJsonConvert.convertList(data),
      pageIndex: pageIndex as int,
      pageSize: pageSize as int,
      count: count as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': this.msg,
      'code': this.code,
      'data': {
        'list': this.data,
        'page_no': this.pageIndex,
        'page_size': this.pageSize,
        'total_count': this.count,
      },
    };
  }
}
