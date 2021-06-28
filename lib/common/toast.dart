import 'package:fluttertoast/fluttertoast.dart';

class Toast{
  static void show(String msg){
    Fluttertoast.showToast(msg: msg,gravity:ToastGravity.CENTER );
  }
}