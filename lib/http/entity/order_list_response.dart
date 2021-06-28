import 'index.dart';

class OrderListResponse {
    List<OrderItem> list;
    int page_no;
    int page_size;
    int total_count;

    OrderListResponse({this.list, this.page_no, this.page_size, this.total_count});

    factory OrderListResponse.fromJson(Map<String, dynamic> json) {
        return OrderListResponse(
            list: json['list'] != null ? (json['list'] as List).map((i) => OrderItem.fromJson(i)).toList() : null,
            page_no: json['page_no'], 
            page_size: json['page_size'], 
            total_count: json['total_count'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['page_no'] = this.page_no;
        data['page_size'] = this.page_size;
        data['total_count'] = this.total_count;
        if (this.list != null) {
            data['orderItem'] = this.list.map((v) => v.toJson()).toList();
        }
        return data;
    }
}