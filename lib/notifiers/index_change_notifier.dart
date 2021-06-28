import 'package:flutter/material.dart';

import '../models/index.dart';
import '../common/index.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/http/entity/index.dart';

class IndexDataChangeNotifier extends ChangeNotifier {
  void update() async {
    notifyListeners();
  }
}
