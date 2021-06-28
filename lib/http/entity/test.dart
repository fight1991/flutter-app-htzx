class test {
    String login_name;
    String mobile;
    String nick_name;
    String org_name;
    String real_name;
    String status;
    String telephone;

    test({this.login_name, this.mobile, this.nick_name, this.org_name, this.real_name, this.status, this.telephone});

    factory test.fromJson(Map<String, dynamic> json) {
        return test(
            login_name: json['login_name'], 
            mobile: json['mobile'], 
            nick_name: json['nick_name'], 
            org_name: json['org_name'], 
            real_name: json['real_name'], 
            status: json['status'], 
            telephone: json['telephone'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['login_name'] = this.login_name;
        data['mobile'] = this.mobile;
        data['nick_name'] = this.nick_name;
        data['org_name'] = this.org_name;
        data['real_name'] = this.real_name;
        data['status'] = this.status;
        data['telephone'] = this.telephone;
        return data;
    }
}