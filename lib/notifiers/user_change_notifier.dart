import 'package:ydsd/common/global.dart';
import 'package:ydsd/http/entity/index.dart';
import 'profile_change_notifier.dart';

class UserChangeNotifier extends ProfileChangeNotifier {
  UserInfo get user => Global.profile.user;

  set user(UserInfo user) {
    if (user?.real_name != Global.profile.user?.real_name) {
      var _now = DateTime.now();
      Global.profile.lastLogin = _now.millisecondsSinceEpoch;
    }
    Global.profile.user = user;
    notifyListeners();
  }
}
