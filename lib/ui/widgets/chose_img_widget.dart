
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydsd/ui/widgets/img_place_holder.dart';

class ChoseImgWidget extends StatelessWidget{
  File imgFile;
  String imgUrl;
  String imgTitle;
  Function doChose;
  Function doDelete;
  ChoseImgWidget({this.imgUrl,this.imgFile,this.imgTitle,this.doChose,this.doDelete});

  @override
  Widget build(BuildContext context) {
   return Container(
      width: 130,
      height: 170,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: InkWell(
              child: Container(margin: EdgeInsets.only(top: 6,right:6 ),
                child: ClipRRect(
                  child: getImageWidget(),
                  borderRadius: BorderRadius.circular(8),
                )
              ),
              onTap: doChose,
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: InkWell(
                child: Visibility(
                  visible: (imgFile!=null||imgUrl!=null),
                  child: Image.asset("assets/images/close_circle.png",width:21 ,height: 21,),
                ),
                onTap: doDelete,
              )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(imgTitle==null?"图片":imgTitle,style: TextStyle(fontSize:14 ,color: Color(0xff333333)),),
          )
        ],

      ),
    );
  }

  getImageWidget() {
    if(imgFile==null&&imgUrl==null){
      return Image.asset("assets/images/add_img.png",width:120 ,height: 120,);
    }else if(imgFile!=null){
      return Image.file(imgFile,width:120 ,height: 120,fit: BoxFit.fill,);
    }else{
      return  CachedNetworkImage(
        imageUrl: imgUrl,
        width: 120,
        height: 120,
        fit: BoxFit.fill,
        placeholder:(context,url)=> ImgPlaceHolder(width: 120,height: 120,),
      );
      //return Image.network(imgUrl,width:120 ,height: 120,fit: BoxFit.fill,);
    }
  }

}
