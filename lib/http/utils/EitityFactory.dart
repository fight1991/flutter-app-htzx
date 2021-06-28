import 'dart:convert';
import 'dart:math';

import 'package:ydsd/http/entity/index.dart';

class EntityFactory{


   static const String ORDER_1 = '{"trade_order_no":"1000001","trade_type":"交易类型1","gmt_create":"1591097779948","status":"待支付","buyer_name":"交易用户1","merchant_name":"收单机构2","total_amount":"1000","operator_name":"账户1","valid_date":"1593764547000","plate_number":"浙A902"}';
  static var ORDER_2 = '{"trade_order_no":"1000002","trade_type":"交易类型2","gmt_create":"1591097779948","status":"已完成","buyer_name":"交易用户2","merchant_name":"收单机构3","total_amount":"600","operator_name":"账户2","valid_date":"1593764547000","plate_number":"浙A9029"}';
  static var ORDER_3 = '{"trade_order_no":"1000003","trade_type":"交易类型3","gmt_create":"1591097779948","status":"待支付","buyer_name":"交易用户3","merchant_name":"收单机构4","total_amount":"6622","operator_name":"账户3","valid_date":"1593764547000","plate_number":"浙A90309"}';
  static var ORDER_4 = '{"trade_order_no":"1000004","trade_type":"交易类型4","gmt_create":"1591097779948","status":"已完成","buyer_name":"交易用户4","merchant_name":"收单机构5","total_amount":"9952335","operator_name":"账户4","valid_date":"1593764547000","plate_number":"浙A2109"}';
  static var ORDER_5 = '{"trade_order_no":"1000005","trade_type":"交易类型5","gmt_create":"1591097779948","status":"待支付","buyer_name":"交易用户5","merchant_name":"收单机构6","total_amount":"656562","operator_name":"账户5","valid_date":"1593764547000","plate_number":"浙A11"}';
  static var ORDER_6 = '{"trade_order_no":"1000006","trade_type":"交易类型6","gmt_create":"1591097779948","status":"已完成","buyer_name":"交易用户6","merchant_name":"收单机构7","total_amount":"366","operator_name":"账户6","valid_date":"1593764547000","plate_number":"浙Acd09"}';

   static OrderListResponse genOrderList() {
     return OrderListResponse(
       page_no: 1,
       page_size: 10,
       total_count: 60,
         list: [
         OrderItem.fromJson(json.decode(ORDER_1)),
         OrderItem.fromJson(json.decode(ORDER_2)),
         OrderItem.fromJson(json.decode(ORDER_3)),
         OrderItem.fromJson(json.decode(ORDER_4)),
         OrderItem.fromJson(json.decode(ORDER_5)),
       ]
     );
   }

  static const   String ORDER_DETAIL = '{"trade_order_no":"D1900099000","trade_type":"加油","gmt_create":1591090135000,"status":"已完成","buyer_name":"快乐悍马","merchant_name":"神经加油站","total_amount":56662,"operator_name":"张站长","valid_date":1591349335000,"pay_date":1591349335000,"plate_number":"金A8009"}';
  static const   String ORDER_DETAIL2 = '{"trade_order_no":"D1900099000","trade_type":"加油","gmt_create":1591090135000,"status":"待支付","buyer_name":"快乐悍马","merchant_name":"神经加油站","total_amount":56662,"operator_name":"张站长","valid_date":1591235278000,"pay_date":1591349335000,"plate_number":"金A8009"}';
  static const   String ORDER_DETAIL3 = '{"trade_order_no":"D1900099000","trade_type":"加油","gmt_create":1591090135000,"status":"已取消","buyer_name":"快乐悍马","merchant_name":"神经加油站","total_amount":56662,"operator_name":"张站长","valid_date":1591235278000,"pay_date":1591349335000,"plate_number":"金A8009"}';
//  static const   String ORDER_DETAIL = '';
  static genOrderDetail() {
    int x = Random().nextInt(2);
    Object res;
    switch(x){
      case 1:
        res=OrderDetailResponse.fromJson(json.decode(ORDER_DETAIL));
        break;
      case 2:
        res=OrderDetailResponse.fromJson(json.decode(ORDER_DETAIL2));
        break;
      default:
        res=OrderDetailResponse.fromJson(json.decode(ORDER_DETAIL3));
        break;
    }
    return res;
  }

}