import 'package:flutter/material.dart';

class ConfirmDialog extends Dialog {
  Widget title;
  Widget content;
  bool willPopScope;
  String leftBtnText;
  VoidCallback leftBtnCallback;
  String rightBtnText;
  VoidCallback rightBtnCallback;

  ConfirmDialog({
    Key key,
    this.title,
    @required this.content,
    this.willPopScope,
    this.leftBtnText,
    this.leftBtnCallback,
    this.rightBtnText,
    this.rightBtnCallback,
  }) : super(key: key);

  ConfirmDialog.simple({
    titleText,
    @required contentText,
    willPopScope = true,
    leftBtnText = "取消",
    leftBtnCallback,
    rightBtnText = "确定",
    rightBtnCallback,
  })  : this.title = titleText == null
            ? null
            : Text(
                "$titleText",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
        this.content = Text(
          "$contentText",
          style: TextStyle(
            color: Color(titleText == null ? 0xFF333333 : 0xFF999999),
            fontSize: titleText == null ? 16 : 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        this.willPopScope = willPopScope,
        this.leftBtnText = leftBtnText,
        this.rightBtnText = rightBtnText,
        this.leftBtnCallback = leftBtnCallback,
        this.rightBtnCallback = rightBtnCallback;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => willPopScope,
      child: Material(
        type: MaterialType.transparency, //透明类型
        child: Center(
          child: SizedBox(
            width: 375.0 * 0.8,
            child: Container(
              decoration: ShapeDecoration(
                color: Color(0xffffffff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(height: 14),
                  Container(
                    child: title,
                    margin: EdgeInsets.only(bottom: 14),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 18),
                    padding: EdgeInsets.only(left: 18, right: 18),
                    child: content,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Visibility(
                        visible: leftBtnText != null,
                        child: Container(
                          height: 40,
                          width: 124,
                          margin: EdgeInsets.only(
                            left: 8,
                            right: 8,
                          ),
                          child: OutlineButton(
                            onPressed: leftBtnCallback,
                            color: Color.fromARGB(255, 43, 98, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              "$leftBtnText",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: rightBtnText != null,
                        child: Container(
                          height: 40,
                          width: 124,
                          margin: EdgeInsets.only(
                            left: 8,
                            right: 8,
                          ),
                          child: FlatButton(
                            onPressed: rightBtnCallback,
                            color: Color.fromARGB(255, 43, 98, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              "$rightBtnText",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
