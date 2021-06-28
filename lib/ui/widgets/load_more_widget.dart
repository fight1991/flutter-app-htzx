import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadMoreWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 15,
              height: 15,
              child:CircularProgressIndicator(strokeWidth: 2,),
            ),
            Text("  加载中....")
          ],
        ),
      ),
    );
  }
  
}