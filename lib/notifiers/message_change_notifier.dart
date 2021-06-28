import 'package:flutter/material.dart';

import '../models/index.dart';
import '../common/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';

class MessageChangeNotifier extends ChangeNotifier {
  static MessageChangeNotifier singleton = MessageChangeNotifier();

  AppApi _appApi = AppApi();

  int _unReadMsgCount = 0;

  bool hasUnreadMsg() {
    return _unReadMsgCount == null ? false : _unReadMsgCount > 0;
  }

  String msgTips() {
    if (_unReadMsgCount == null) {
      return "";
    }
    return _unReadMsgCount >= 100 ? "99+" : "$_unReadMsgCount";
  }

  Future doRequestUnreadMsgCountApi() async {

  }
}
