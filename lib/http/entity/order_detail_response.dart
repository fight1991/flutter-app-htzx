import 'package:ydsd/http/index.dart';
import 'package:intl/intl.dart';

class OrderDetailResponse {
    String buyer_name;
    int gmt_create;
    String merchant_name;
    String operator_name;
    String plate_number;
    String status;
    int total_amount;
    String trade_order_no;
    String trade_type;
    int valid_date;
    int pay_date;

    int close_date;
    OrderDetailResponse({this.buyer_name,this.pay_date, this.gmt_create, this.merchant_name, this.operator_name, this.plate_number, this.status, this.total_amount, this.trade_order_no, this.trade_type, this.valid_date,this.close_date});

    factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
        return OrderDetailResponse(
            buyer_name: json['buyer_name'], 
            gmt_create: json['gmt_create'], 
            merchant_name: json['merchant_name'], 
            operator_name: json['operator_name'], 
            plate_number: json['plate_number'], 
            status: json['status'], 
            total_amount: json['total_amount'], 
            trade_order_no: json['trade_order_no'], 
            trade_type: json['trade_type'], 
            valid_date: json['valid_date'],
            pay_date: json['pay_date'],
            close_date: json['close_date'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['buyer_name'] = this.buyer_name;
        data['gmt_create'] = this.gmt_create;
        data['merchant_name'] = this.merchant_name;
        data['operator_name'] = this.operator_name;
        data['plate_number'] = this.plate_number;
        data['status'] = this.status;
        data['total_amount'] = this.total_amount;
        data['trade_order_no'] = this.trade_order_no;
        data['trade_type'] = this.trade_type;
        data['valid_date'] = this.valid_date;
        data['pay_date'] = this.pay_date;
        data['close_date'] = this.close_date;
        return data;
    }

    ///分转元
  String getYuan() {
      if(total_amount!=null)
          return (total_amount/100).toStringAsFixed(2)+"元";
      return "--元";
  }

  getCreatTime() {
      if(gmt_create!=null){
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(gmt_create*1000);
          return DateFormat("yyyy-MM-dd. HH:mm").format(dt).toString();
      }else{
          return "--年--月--日";
      }
  }

  getTimeLast() {
      if(valid_date!=null){
          if(valid_date*1000>RpcTimeInterceptor.getServerUTCTime()){
              int secondLast = ((valid_date*1000-RpcTimeInterceptor.getServerUTCTime())/1000).round();
              int minute = (secondLast/60).floor();
              int second = secondLast%60;
              return "$minute分$second秒";
          }else{
              return null;
          }

      }
      return null;
  }

  getPayTime() {
      if(pay_date!=null){
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(pay_date*1000);
          return DateFormat("yyyy-MM-dd. HH:mm").format(dt).toString();
      }else{
          return "--年--月--日";
      }
  }
    getCloseTime() {
      if(close_date!=null){
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(close_date*1000);
          return DateFormat("yyyy-MM-dd. HH:mm").format(dt).toString();
      }else{
          return "--年--月--日";
      }
  }
}