import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImgPlaceHolder extends StatelessWidget{
  double width;
  double height;
  ImgPlaceHolder({this.width,this.height});

  @override
  Widget build(BuildContext context) {
   return Container(
      width: this.width,
      height: this.height,
      decoration: BoxDecoration(
          color: Color(0xffffffff),
          border:Border.all(width: 0.5,color: Color(0xffcccccc) ),
          borderRadius: BorderRadius.all(Radius.circular(8))
      ),
     child: Center(
       child: CircularProgressIndicator(strokeWidth: 1,
         backgroundColor:Color(0xffffffff),
           valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffcccccc))),
     ),
    );
  }

}