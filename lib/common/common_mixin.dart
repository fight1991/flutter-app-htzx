import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ydsd/ui/index.dart';

mixin UtilWidgetMixin {

  void showAlert({
    BuildContext context,
    String title,
    String content,
    String leftBtnText = '取消',
    String rightBtnText = '确定',
    Function leftBtnCallback,
    Function rightBtnCallback
  }) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: title != null ? Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
                title ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18
                )
            ),
          ) : null,
          content: content != null ? Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text(content),
          ): null,
          leftBtnText: leftBtnText,
          rightBtnText: rightBtnText,
          leftBtnCallback: leftBtnCallback,
          rightBtnCallback: rightBtnCallback,
        );
      });
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER);
  }

  Future<Null> showLoading(BuildContext context, {String text="加载中"}) {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
          text: text,
        );
      });
  }

  void hideOverlay(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future sleep(int milliseconds) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  void showFullLoading({ BuildContext context, Color barrierColor = Colors.black26 }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return SafeArea(
          child: Builder(
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator());
            }
          ),
        );
      },
      barrierDismissible: false,
      barrierColor: barrierColor,
      transitionDuration: Duration.zero,
    );
  }
}