import 'package:flutter/services.dart';

class PriceInputFormatter extends TextInputFormatter{
  int _scale;
  PriceInputFormatter(this._scale);
  RegExp exp = new RegExp("[0-9.]");
  static const String POINTER = ".";
  static const String DOUBLE_ZERO = "00";
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    ///输入完全删除
    if (newValue.text.isEmpty) {
      return TextEditingValue();
    }

    ///只允许输入小数
    if (!exp.hasMatch(newValue.text)) {
      return oldValue;
    }

    ///包含小数点的情况
    if (newValue.text.contains(POINTER)) {
      ///包含多个小数
      if (newValue.text.indexOf(POINTER) !=
          newValue.text.lastIndexOf(POINTER)) {
        return oldValue;
      }
      String input = newValue.text;
      int index = input.indexOf(POINTER);

      ///小数点后位数
      int lengthAfterPointer = input.substring(index, input.length).length - 1;

      ///小数位大于精度
      if (lengthAfterPointer > _scale) {
        return oldValue;
      }
      ///不能以点开头
      if(input.startsWith(POINTER)){
        return oldValue;
      }
    } else if (newValue.text.startsWith(POINTER) ||
        newValue.text.startsWith(DOUBLE_ZERO)) {
      ///不包含小数点,不能以“00”开头
      return oldValue;
    }else{
      //只能输入数字
      try{
        double yuan = double.parse(newValue.text);
        //最大输入999999.99
        if(yuan>999999.99){
          return oldValue;
        }
      }catch(e){
        return oldValue;
      }
    }
    return newValue;
  }

}