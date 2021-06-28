import 'package:flutter/material.dart';
import 'package:ydsd/common/global.dart';
import 'profile_change_notifier.dart';

class ThemeChangeNotifier extends ProfileChangeNotifier {
  ColorSwatch get theme =>
      Global.themes.firstWhere((e) => e.value == Global.profile.theme,
          orElse: () => Colors.blueGrey);

  set theme(ColorSwatch colorSwatch) {
    if (colorSwatch != theme) {
      Global.profile.theme = colorSwatch[500].value;
      notifyListeners();
    }
  }

  Brightness get brightness =>
      WidgetsBinding.instance.window.platformBrightness;
}
