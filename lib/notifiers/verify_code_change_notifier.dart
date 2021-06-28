import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/notifiers/profile_change_notifier.dart';

class VerifyCodeChangeNotifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
