import 'package:flutter/material.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/notifiers/profile_change_notifier.dart';

class LocaleChangeNotifier extends ProfileChangeNotifier {
  Locale getLocale() {
    var _locale = this.locale;
    if (_locale == null) return null;
    var t = _locale.split("_");
    return Locale(t[0], t[1]);
  }

  String get locale => Global.profile.locale;

  set locale(String locale) {
    if (locale != this.locale) {
      Global.profile.locale = locale;
      notifyListeners();
    }
  }
}
