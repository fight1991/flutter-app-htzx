import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  static String statusLoading = "loading";
  static String statusEmpty = "empty";
  static String statusError = "error";
  static String statusSuccess = "success";

  String status;
  String loadingText;
  String emptyText;
  String errorText;
  String retryBtnText;
  VoidCallback retry;
  Widget child;

  StatusWidget({
    Key key,
    this.status,
    this.loadingText,
    this.emptyText,
    this.errorText,
    this.retryBtnText,
    this.retry,
    this.child,
  });

  StatusWidget.empty({text})
      : this.status = statusEmpty,
        this.emptyText = text == null ? "数据为空" : text;

  StatusWidget.loading({text})
      : this.status = statusLoading,
        this.loadingText = text;

  StatusWidget.error({text, retryText, VoidCallback retry})
      : this.status = statusError,
        this.errorText = text,
        this.retryBtnText = retryText == null ? "点击重试" : retryText,
        this.retry = retry;

  StatusWidget.success({child})
      : this.status = statusSuccess,
        this.child = child;

  @override
  Widget build(BuildContext context) {
    if (status == statusLoading) {
      return _buildLoading(context);
    } else if (status == statusEmpty) {
      return _buildEmpty(context);
    } else if (status == statusError) {
      return _buildError(context);
    } else if (status == statusSuccess) {
      return _buildError(context);
    }
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(errorText),
          Visibility(
            visible: retry == null,
            child: RaisedButton(
              child: Text("$retryBtnText"),
              onPressed: retry,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          Visibility(
            visible: loadingText == null,
            child: Text(
              "$loadingText",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Image.asset(
              "assets/images/empty.png",
              height: 155,
              width: 114,
              fit: BoxFit.scaleDown,
            ),
          ),
          Text(
            "$emptyText",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
