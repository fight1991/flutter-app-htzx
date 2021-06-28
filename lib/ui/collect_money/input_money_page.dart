
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ydsd/channel/index.dart';
import 'package:ydsd/common/environment_config.dart';
import 'package:ydsd/common/index.dart';
import 'package:ydsd/common/toast.dart';
import 'package:ydsd/http/index.dart';
import 'package:ydsd/ui/widgets/price_input_formatter.dart';

import '../index.dart';

class InputMoneyPage extends StatefulWidget{
  static const String CAR_NO ="car_no";
  static const String CID ="cid";
  String carNo;
  String cid;

  @override
  State<StatefulWidget> createState() {
    return InputMoneyState();
  }

}
class InputMoneyState extends State<InputMoneyPage>{
  AppApi _appApi = AppApi();
  ApiStatus<AppApiResponse> _submitAcquiringStatus;

  TextEditingController _inputControl = TextEditingController();
  String _inputMoney="";
  var args;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      args = ModalRoute.of(context).settings.arguments;
      widget.carNo = args[InputMoneyPage.CAR_NO];
      widget.cid = args[InputMoneyPage.CID];
    });
    _inputControl.addListener(() {
      setState(() {
        _inputMoney=_inputControl.text;
      });
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2B61FF),
        centerTitle: false,
        title: Text(
          "输入金额",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Color(0xff2B61FF),
                width: double.infinity,
                padding: EdgeInsets.only(top: 16,bottom: 16,left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "车辆号牌：",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 12,),
                    ),
                    Padding(padding: EdgeInsets.only(top: 8),
                      child: Text(
                        widget.carNo??"",
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 24,),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24,right: 24,top: 5,bottom: 5),
                child: Row(
                  children: <Widget>[
                    Text(
                      "￥  ",
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontWeight: FontWeight.w500,
                        fontSize: 32,
                      ),),
                    Expanded(
                      child: TextField(
                        controller: _inputControl,
                        autofocus: true,
                        cursorColor: Color(0xFF2B61FF),
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 32,
                        ),
                        keyboardType: TextInputType.number,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: "输入金额",
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 32,
                          ),
                          border: InputBorder.none,
                        ),
                        inputFormatters: [PriceInputFormatter(2)],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24,right: 24),
                color: Color(0xff2B61FF),
                width: double.infinity,
                height: 0.5,
              ),
              Container(
                height: 48,
                width: 335,
                margin: EdgeInsets.only(top: 8),
                child: FlatButton(
                  onPressed: (_inputMoney!=null&&_inputMoney.trim()!="")?_doSubmite:null,
                  color: Color(0xFF2B61FF),
                  disabledColor: Color(0xFFCCCCCC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    "确定",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  void _doSubmite()async {
    ///发起付款
    String value = _inputControl.text;
    if(value==null){
      print("请输入正确的金额");
      return;
    }
    int total_amount;
    try{
       total_amount =  (double.parse(value)*100).round();
    }catch(e){

    }
    if(total_amount==null||total_amount==0){
        Toast.show("请输入正确的金额");
        return;
    }
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            text: '加载中...',
          );
        });


    try {
      if(_submitAcquiringStatus==null){
        _submitAcquiringStatus = new  ApiStatus(this.context);
      }
      _submitAcquiringStatus.reset();
      String deviceCode;

      if(Global.isBenNengDevice()){
          deviceCode = await AppMethodChannel.getBNDeviceCode();
          print("bnDeviceCode:$deviceCode");
      }else{
        deviceCode =await AppMethodChannel.getHuaTuoDeviceCode();
      }
      print("确认收款,total_amount:$total_amount,deviceCode:$deviceCode,cid:${widget.cid}");
      var response;
      if(Global.isRelease){
        response = await _appApi.submitAcquiring(widget.cid,total_amount,deviceCode);
      }else{
        //AppMethodChannel.brScan() = 10 模拟付款成功
        //remark = 20 模拟付款失败-
        String remark = "10";
//        int rd = Random().nextInt(3);
//        if(rd==0){
//          remark = "10";
//        }else if (rd==1){
//          remark = "20";
//        }else if (rd==2){
//          remark = "30";
//        }
        print("商户确认收款 remark=$remark");
//        Toast.show("remark=$remark");
        response = await _appApi.submitAcquiring(widget.cid,total_amount,deviceCode,remark: remark);
      }
      _submitAcquiringStatus.apiSuccess(response);
    } catch (onError) {
      _submitAcquiringStatus.apiError(onError);
    }
    Navigator.pop(context, true);
    var  orderNo = _submitAcquiringStatus.apiResponse?.data;
    if (_submitAcquiringStatus.isServiceSuccess()) {
      //发起成功  交易订单号
      Navigator.of(context).pushNamed(PageName.collectionSuccess,
          arguments: {CollectionSuccessPage.ORDER_NO:orderNo,
            CollectionSuccessPage.TOTAL_AMOUNT:_inputControl.text,
          }).then((value) => Navigator.of(context).pop());
      return;
    }
    //处理中
    if(_submitAcquiringStatus.apiResponse?.code==2050){
      Toast.show(_submitAcquiringStatus.apiResponse.msg);
      //处理中页面
      Navigator.of(context).pushNamed(PageName.collectionWaiting,
          arguments: {CollectionWaittingPage.ORDER_NO:orderNo,
              CollectionWaittingPage.TOTAL_AMOUNT:_inputControl.text,}).then((value) => Navigator.of(context).pop());
      return;
    }
    //设备权限不符，请联系客服
    print("code:${_submitAcquiringStatus.apiResponse?.code},${_submitAcquiringStatus.apiResponse?.code==2053}");
    if(_submitAcquiringStatus.apiResponse?.code==2053){
        Toast.show("设备权限不符，请联系客服.");
        Navigator.of(context).pop();
        return;
    }
    //失败,失败页面
    Toast.show(_submitAcquiringStatus.apiResponse?.msg);
    Navigator.of(context).pushNamed(PageName.collectionError,
        arguments: {CollectionErrorPage.ORDER_NO:orderNo,
          CollectionErrorPage.ERROR_MSG:_submitAcquiringStatus.apiResponse?.msg??""

        }).then((value) => Navigator.of(context).pop());
    return;
    Toast.show(_submitAcquiringStatus.apiResponse.msg);

  }



}

