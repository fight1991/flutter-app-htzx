class CidCarDetail {
    String plate_number;
    String real_name;
    String trade_order_no;
    int user_id;

    CidCarDetail({this.plate_number, this.real_name, this.trade_order_no, this.user_id});

    factory CidCarDetail.fromJson(Map<String, dynamic> json) {
        return CidCarDetail(
            plate_number: json['plate_number'], 
            real_name: json['real_name'], 
            trade_order_no: json['trade_order_no'], 
            user_id: json['user_id'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['plate_number'] = this.plate_number;
        data['real_name'] = this.real_name;
        data['trade_order_no'] = this.trade_order_no;
        data['user_id'] = this.user_id;
        return data;
    }
}