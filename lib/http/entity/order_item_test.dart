class order_item_test {
    String biz_order_no;
    int buyer_id;
    String buyer_name;
    String cid;
    int close_date;
    String close_reason;
    String creator;
    String device_code;
    int gmt_create;
    int gmt_modify;
    String goods_summary;
    int id;
    String merchant_name;
    int merchant_user_id;
    String modifier;
    int operator_id;
    String operator_name;
    int pay_date;
    String pay_status;
    String plate_number;
    String remark;
    String status;
    int total_amount;
    String trade_order_no;
    String trade_type;
    int valid_date;

    order_item_test({this.biz_order_no, this.buyer_id, this.buyer_name, this.cid, this.close_date, this.close_reason, this.creator, this.device_code, this.gmt_create, this.gmt_modify, this.goods_summary, this.id, this.merchant_name, this.merchant_user_id, this.modifier, this.operator_id, this.operator_name, this.pay_date, this.pay_status, this.plate_number, this.remark, this.status, this.total_amount, this.trade_order_no, this.trade_type, this.valid_date});

    factory order_item_test.fromJson(Map<String, dynamic> json) {
        return order_item_test(
            biz_order_no: json['biz_order_no'], 
            buyer_id: json['buyer_id'], 
            buyer_name: json['buyer_name'], 
            cid: json['cid'], 
            close_date: json['close_date'], 
            close_reason: json['close_reason'], 
            creator: json['creator'], 
            device_code: json['device_code'], 
            gmt_create: json['gmt_create'], 
            gmt_modify: json['gmt_modify'], 
            goods_summary: json['goods_summary'], 
            id: json['id'], 
            merchant_name: json['merchant_name'], 
            merchant_user_id: json['merchant_user_id'], 
            modifier: json['modifier'], 
            operator_id: json['operator_id'], 
            operator_name: json['operator_name'], 
            pay_date: json['pay_date'], 
            pay_status: json['pay_status'], 
            plate_number: json['plate_number'], 
            remark: json['remark'], 
            status: json['status'], 
            total_amount: json['total_amount'], 
            trade_order_no: json['trade_order_no'], 
            trade_type: json['trade_type'], 
            valid_date: json['valid_date'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['biz_order_no'] = this.biz_order_no;
        data['buyer_id'] = this.buyer_id;
        data['buyer_name'] = this.buyer_name;
        data['cid'] = this.cid;
        data['close_date'] = this.close_date;
        data['close_reason'] = this.close_reason;
        data['creator'] = this.creator;
        data['device_code'] = this.device_code;
        data['gmt_create'] = this.gmt_create;
        data['gmt_modify'] = this.gmt_modify;
        data['goods_summary'] = this.goods_summary;
        data['id'] = this.id;
        data['merchant_name'] = this.merchant_name;
        data['merchant_user_id'] = this.merchant_user_id;
        data['modifier'] = this.modifier;
        data['operator_id'] = this.operator_id;
        data['operator_name'] = this.operator_name;
        data['pay_date'] = this.pay_date;
        data['pay_status'] = this.pay_status;
        data['plate_number'] = this.plate_number;
        data['remark'] = this.remark;
        data['status'] = this.status;
        data['total_amount'] = this.total_amount;
        data['trade_order_no'] = this.trade_order_no;
        data['trade_type'] = this.trade_type;
        data['valid_date'] = this.valid_date;
        return data;
    }
}