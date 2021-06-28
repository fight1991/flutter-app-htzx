import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../http/mock_interceptor.dart';
import "../models/index.dart";

class PageName {
  static String splash = "/splash";
  static String main = "/main";
  static String minePage = "/mine_page";

  static String about = "/about"; //关于页面
  static String message = "/message"; //消息中心页面
  static String passwordLogin = "/passwordLogin"; //密码登录
  static String changePassword = "/changePassword"; //修改密码
  static String qrcodeGen = "/qrcodeGen"; //二维码扫描
  static String qrcodeScan = "/qrcodeScan"; //生成二维码
  static String orderList = "/orderList"; //订单列表
  static String orderDetail = "/orderDetail"; //订单详情
  static String orderSearch = "/orderSearch"; //订单详情
  static String scanPage = "/scanPage"; //扫码首页，发起收款
  static String bnScanPage = "/bnScanPage"; //扫码首页，发起收款
  static String bNDeviceManagerPagePage = "/BNDeviceManagerPagePage"; //本能搜索连接设备
  static String inputMoney = "/inputMoney"; //输入金额
  static String collectionSuccess = "/collectionSuccess"; //收款成功
  static String collectionError = "/collectionError"; //收款失败
  static String collectionWaiting = "/collectionWaiting"; //收款处理中
  static String webview = "/webview"; //加载网页页面
  static String feedback = "/feedback"; //微信客服页面
  static String test = "/test";
  static String imagePicker = "/image_picker";
  static String userInfo = "/userInfo";//用户信息
  static String language = "/language"; //
  static String theme = "/theme";
}
