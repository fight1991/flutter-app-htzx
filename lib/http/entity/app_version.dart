import 'package:json_annotation/json_annotation.dart';

class AppVersion {
    @JsonKey(name: "app_name")
    String app_name;
    @JsonKey(name: "app_os")
    String app_os;
    @JsonKey(name: "build_num")
    String build_num;
    @JsonKey(name: "description")
    String description;
    @JsonKey(name: "download_url")
    String download_url;
    @JsonKey(name: "id")
    int id;
    @JsonKey(name: "package_md5")
    String package_md5;
    @JsonKey(name: "publish_date")
    int publish_date;
    @JsonKey(name: "remind_frequency")
    String remind_frequency;
    @JsonKey(name: "require_install")
    int require_install;
    @JsonKey(name: "title")
    String title;
    @JsonKey(name: "version")
    String version;

    AppVersion({this.app_name, this.app_os, this.build_num, this.description, this.download_url, this.id, this.package_md5, this.publish_date, this.remind_frequency, this.require_install, this.title, this.version});

    factory AppVersion.fromJson(Map<String, dynamic> json) {
        return AppVersion(
            app_name: json['app_name'], 
            app_os: json['app_os'], 
            build_num: json['build_num'], 
            description: json['description'], 
            download_url: json['download_url'], 
            id: json['id'], 
            package_md5: json['package_md5'], 
            publish_date: json['publish_date'], 
            remind_frequency: json['remind_frequency'], 
            require_install: json['require_install'], 
            title: json['title'], 
            version: json['version'], 
        );
    }

    bool get isMustInstall => require_install==1;

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['app_name'] = this.app_name;
        data['app_os'] = this.app_os;
        data['build_num'] = this.build_num;
        data['description'] = this.description;
        data['download_url'] = this.download_url;
        data['id'] = this.id;
        data['package_md5'] = this.package_md5;
        data['publish_date'] = this.publish_date;
        data['remind_frequency'] = this.remind_frequency;
        data['require_install'] = this.require_install;
        data['title'] = this.title;
        data['version'] = this.version;
        return data;
    }
}