# 移动收单

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


生成国际化的配置
```
//根据dart代码生成arb文件
flutter pub pub run intl_translation:extract_to_arb --output-dir=i18n-arb \ lib/i18n/index.dart
```

```
//根据arb文件生成dart代码
flutter pub run intl_translation:generate_from_arb --output-dir=lib/i18n --no-use-deferred-loading lib/i18n/index.dart i18n-arb/intl_*.arb
```

```
//生成JSON的解析代码
//一次性生成
flutter pub run build_runner build --delete-conflicting-outputs
//监听文件的状态来持续生成
flutter pub run build_runner watch --delete-conflicting-outputs
```

//flutter安卓打包--测试（flutter 版本大于等于1.17）
flutter build apk   --dart-define=IS_RELEASE=false  --target-platform  android-arm -v
//flutter安卓打包--生产
flutter build apk   --dart-define=IS_RELEASE=true  --target-platform  android-arm -v

华拓启动流程：
    设备启动流程(其中上电为固定流程，不可改变 )MainActivity onCreate -> initHuaTuoDevice() -> ScanService.startService() -> initDevices()
华拓断电流程（流程固定不可改变）：
    ScanService.closeDevices()
华拓扫码发起流程（flutter端发起）：
    flutter端ScanPage页面监控键盘事件，通知android原生发起扫描请求：
                    if ( rawKeyEventDataAndroid?.keyCode == 135) {
                       _doScan();
                     }
    android原生接受flutter短发来的扫描指令 'huatuoScan'  ->MainActivity  ScanService.startScan(MainActivity.this); -> ScanService.doScan() 以下为固定读写流程，不可改变
华拓扫码结果获取流程：
    SctReadThread. case SctData.FRAME_TYPE_RFID_INFO -> if(user_x == 0){bundle.putSerializable("sctData", rec_SctData);} ->
    RfHandle case 5:  String cid = sctFrameMsg.getData("8801").getValue();  ->sendBroadcast(new Intent(SCAN_CID_ACTION))
    -> MainActivity: CIDRecive.onReceive 通知flutter 读取cid结果

本能2设备启动流程：
    MainActivity.onCreate()-> BNScannerRequest.get() ->BNScannerRequest.pownerOn()
本能2设备断电
    BNScannerRequest.pownerOn()
本能2按键监控（android原生发起读取）：
    MainActivity:mKeyReceiver = KeyReceiver.register(this)
    KeyReceiver.onReceive():
    case KeyEvent.KEYCODE_F3:,case KeyEvent.KEYCODE_F5: 读取一次cid：BNScannerRequest.get().singleRead();
本能2读取结果：
    BNScannerRequest：Handler.handleMessage:
    case 0://可以拿数据(仅这个case有用)
        JSONObject jsonObj = handSetControl.getTagVehicleInfo();
                                if(jsonObj!=null){
                                    BNScannerResponse.get().readDataSuccess(jsonObj);
                                    Log.e(TAG, jsonObj.toString());
                                }
    其他case为‘本能1.0’设备用的，现在可忽略之 如（ case 3:case 0xBC:，case 0xAB:，case 0xBB:）等等

省电作用：
MainActivity中监控屏幕灭屏，如果灭屏则退出程序，从而节省电量
    MainActivity.ScreenReceiver ->ScreenReceiver.onReceive():
       else if(Intent.ACTION_SCREEN_OFF.equals(action)) :屏幕关闭
