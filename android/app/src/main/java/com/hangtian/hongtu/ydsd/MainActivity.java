package com.hangtian.hongtu.ydsd;

import android.Manifest;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.Uri;
import android.nfc.Tag;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

//import com.hangtian.hongtu.AliyunPush;
import com.hangtian.hongtu.BNScannerRequest;
import com.hangtian.hongtu.BNScannerResponse;
import com.hangtian.hongtu.BlueToothUtil;
import com.hangtian.hongtu.KeyReceiver;
import com.hangtian.hongtu.events.BNReadDataEvent;
import com.hangtian.hongtu.events.DeviceAlarmEvent;
import com.hangtian.hongtu.events.DeviceConnectedEvent;
import com.hangtian.hongtu.events.DeviceDisConnectedEvent;
import com.hangtian.hongtu.events.DeviceFoundEvent;
import com.hangtian.hongtu.events.SearchStopedEvent;
import com.hangtian.hongtu.huatuoscan.Logger;
import com.hangtian.hongtu.huatuoscan.ScanService;
import com.hangtian.hongtu.huatuoscan.verifyUtils.UtilsTool;
import com.hangtian.hongtu.service.KeepLifeService;
import com.umeng.analytics.MobclickAgent;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String LOGTAG = "MainActivity";
    private static final String channelName = "com.hangtian.hongtu.ydsd/AppMethodChannel";
    private static final String eventChannelName = "com.hangtian.hongtu.ydsd/HomePageEventChannel";

    private static final int REQUEST_CODE_MAIN = 1000;
    private static final int REQUEST_CODE_PERMISSIONS = 1001;
    private static final int REQUEST_CODE_Location = 1002;
    private static final int REQUEST_MUST_Location = 1003;
    private static final int REQUEST_BN_SCAN = 1004;

    private static final String ERROR_CODE_FAILED = "-1";
    private static final String ERROR_CODE_NO_PERMISSIONS = "-2";
    private static final String ERROR_CODE_NO_PERMISSIONS_AND_NO_TIPS = "-3";

    private MethodChannel appMethodChannel;
    private MethodChannel.Result faceAuthResult;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    private AlertDialog mNavDialog;
    private String mFilePath;


    CIDRecive mCidReceiver;
    ScreenReceiver mScreenReceiver;
    Handler mHandler = new Handler();
    BlockingQueue<String> mBlockQueue = new ArrayBlockingQueue<String>(4);
    KeyReceiver mKeyReceiver;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        checkPermission();

        FlutterEngine flutterEngine = getFlutterEngine();
        DartExecutor dartExecutor = flutterEngine.getDartExecutor();

        initEventChannel(dartExecutor);
        initMethodChannel(dartExecutor);

        NotifiUtil.showNotif(this,"欢迎","欢迎使用小蛮腰APP");

        if(getIntent()!=null){
            doUri(getIntent().getData());
        }
        //华拓
        initHuaTuoDevice();
        registerEventBus();
        //本能
        BNScannerRequest.get();
        startService(new Intent(this, KeepLifeService.class));
        mKeyReceiver = KeyReceiver.register(this);
        showDeviceLoading();
    }

    /**
     * 本能扫描到新设备
     * @param event
     */
//    @Subscribe(threadMode = ThreadMode.MAIN, sticky = false, priority = 0)
//    public void onDeviceFoundEvent(DeviceFoundEvent event) {
//        Map<String,String>eventMap = new HashMap<>();
//        eventMap.put("event","bn_device_found");
//        eventMap.put("devices",event.nameAddress.toString());
//        eventSink.success(eventMap);
//    }

    /**
     * 本能停止搜索设备
     * @param event
     */
//    @Subscribe(threadMode = ThreadMode.MAIN, sticky = false, priority = 0)
//    public void onSearchStopedEvent(SearchStopedEvent event) {
//        Map<String,String>eventMap = new HashMap<>();
//        eventMap.put("event","bn_search_stop");
//        eventSink.success(eventMap);
//    }
    /**
     * 本能设备连接成功
     * @param event
     */
//    @Subscribe(threadMode = ThreadMode.MAIN, sticky = false, priority = 0)
//    public void onDeviceConnectedEvent(DeviceConnectedEvent event) {
//        Map<String,String>eventMap = new HashMap<>();
//        eventMap.put("event","bn_connected");
//        eventSink.success(eventMap);
//    }
    /**
     * 本能断开连接
     * @param event
     */
//    @Subscribe(threadMode = ThreadMode.MAIN, sticky = false, priority = 0)
//    public void onDeviceDisConnectedEvent(DeviceDisConnectedEvent event) {
//        Map<String,String>eventMap = new HashMap<>();
//        eventMap.put("event","bn_discnnected");
//        eventSink.success(eventMap);
//    }
    /**
     * 本能读取到cid
     * @param event
     */
    @Subscribe(threadMode = ThreadMode.MAIN, sticky = false, priority = 0)
    public void onBNReadDataEvent(BNReadDataEvent event) {
        Map<String,String>eventMap = new HashMap<>();
        eventMap.put("event","bn_cid");
        eventMap.put("cid",event.cid);
        eventSink.success(eventMap);
    }
    /**
     * 本能设备报警
     * @param event
     */
    @Subscribe(threadMode = ThreadMode.MAIN, sticky = false, priority = 0)
    public void onDeviceAlarmEvent(DeviceAlarmEvent event) {
        Map<String,String>eventMap = new HashMap<>();
        eventMap.put("event","bn_device_alarm");
        eventMap.put("alarm",event.alarmContent);
        eventSink.success(eventMap);
    }


    private void initHuaTuoDevice() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(ScanService.SCAN_CID_ACTION);
        mCidReceiver = new CIDRecive();
        registerReceiver(mCidReceiver,filter);
        ScanService.startService(this);

        IntentFilter screenFilter = new IntentFilter();
        screenFilter.addAction(Intent.ACTION_SCREEN_ON);
        screenFilter.addAction(Intent.ACTION_SCREEN_OFF);
        mScreenReceiver = new ScreenReceiver();
        registerReceiver(mScreenReceiver,screenFilter);
    }

    private void initMethodChannel(DartExecutor dartExecutor) {
        if (appMethodChannel == null) {
            Log.i(LOGTAG, "init appMethodChannel:" + channelName);
            appMethodChannel = new MethodChannel(dartExecutor, channelName);
            appMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                @Override
                public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                    if ("onUmEvent".equals(call.method)) {
                        String eventId = call.argument("eventId");
                        Map<String, Object> map = call.argument("map");
                        if (!TextUtils.isEmpty(eventId)) {
                            Log.i(LOGTAG, "umOnEvent:" + eventId);
                            if (map != null && map.size() > 0) {
                                MobclickAgent.onEventObject(getApplication(), eventId, map);
                            } else {
                                MobclickAgent.onEvent(getApplication(), eventId);
                            }

                        }
                        result.success("unKnow");
                        return;
                    }else if("huatuoScan".equals(call.method)){
                        //扫描电子车牌
                        ScanService.startScan(MainActivity.this);
                        result.success("unKnow");
                    }else if("huatuoDeviceCode".equals(call.method)){
                        String huatuoDeviceCode = UtilsTool.getUuid();
                        result.success(huatuoDeviceCode);
                    }
                    else if ("bindAlias".equals(call.method)) {
                        String alias = call.argument("alias");
                        result.success("unKnow");
//                        AliyunPush.bindAlias(alias, getApplication());
                        return;
                    }else if ("bn_search_device".equals(call.method)) {
                        //本能搜索设备
//                        checkBNRequest();
//                        result.success("unKnow");
                        return;
                    }else if ("bn_connect_device".equals(call.method)) {
                        //本能连接
//                        String address = call.argument("address");
//                        boolean res = BNScannerRequest.get().connectDevice(MainActivity.this,address);
//                        result.success(res);
                        return;
                    }else if ("bn_disconnect_device".equals(call.method)) {
                        //本能断开连接
//                        String address = call.argument("address");
//                        boolean res = BNScannerRequest.get().disConnectDevice(MainActivity.this,address);
//                        Log.i(LOGTAG,"bn_disconnect_device,address："+address);
//                        result.success(res);
                        return;
                    }else if ("bn_device_id".equals(call.method)) {
                        //本能获取deviceId
                       final  BNScannerRequest req = BNScannerRequest.get();
                        new Thread(){
                            @Override
                            public void run() {
                                super.run();
                                final String deviceID = req.getDeviceId();
                                new Handler(Looper.getMainLooper()).post(
                                        new Runnable() {
                                            @Override
                                            public void run() {
                                                result.success(deviceID);
                                            }
                                        }
                                );

                            }
                        }.start();

                        return;
                    }

                    else if ("requestLocation".equals(call.method)) {
                        result.success("unKnow");
                        return;
                    } else if ("getHtDeviceId".equals(call.method)) {
                        //pushid 收单暂时没有
                        result.success("unKnow");
                        return;
                    } else {
                        result.notImplemented();
                    }
                }
            });
        }
    }

    private static final int BLUETOOTH_REQUESTCODE = 1005;
//    private void checkBNRequest() {
//        if (Build.VERSION_CODES.M > Build.VERSION.SDK_INT) {
//            openAndSearch();
//        } else {
//            String[] permissions = {Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION};
//            requestPermissions(permissions, REQUEST_BN_SCAN);
//        }
//    }

//    private void openAndSearch() {
//        if(!BlueToothUtil.isBlueToothEnable()){
//            Toast.makeText(this,"该设备不支持蓝牙",Toast.LENGTH_SHORT).show();
//            stopScanAnim();
//            return;
//        }
//        if(BlueToothUtil.openBlueTooth(this,BLUETOOTH_REQUESTCODE)){
//            BNScannerRequest.get().searchDevice(MainActivity.this);
//        }
//    }

    private void initEventChannel(DartExecutor dartExecutor) {
        if (eventChannel == null) {
            eventChannel = new EventChannel(dartExecutor, eventChannelName);
            eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object arguments, EventChannel.EventSink events) {
                    eventSink = events;
                    new Thread(){
                        @Override
                        public void run() {
                            super.run();
                            while (true){
                                try {
                                    String uri = mBlockQueue.take();
                                    mHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            Map<String,String>eventMap = new HashMap<>();
                                            eventMap.put("event","uri");
                                            eventMap.put("uri",uri);
                                            Log.i(LOGTAG,"eventShink.success "+uri);
                                            eventSink.success(eventMap);
                                        }
                                    });
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }.start();

                }

                @Override
                public void onCancel(Object arguments) {

                }
            });
        }
    }

    private void doUri(Uri uri) {
        Log.i(LOGTAG, "doUri:"+((uri==null)?"null":uri.toString()));
        if(uri!=null){
            String scheme = uri.getScheme();
            String host = uri.getHost();
            String path = uri.getPath();
            mBlockQueue.add(uri.toString());

        }
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        doUri(intent.getData());
    }

    //检查必要权限
    private void checkPermission() {
        LocationManager locManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);

        if (Build.VERSION_CODES.M > Build.VERSION.SDK_INT) {
            //doNothing
        } else {
            String[] permissions = {Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION};
            requestPermissions(permissions, REQUEST_MUST_Location);
        }

    }

    private void showAlert(String msg) {
        new AlertDialog.Builder(this)
                .setMessage(msg)
                .setNegativeButton("退出", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        finish();
                    }
                }).setPositiveButton("确定", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                checkPermission();
            }
        }).setCancelable(false).create().show();
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.i(LOGTAG, "onActivityResult, requestCode:" + requestCode + ", resultCode:" + resultCode);
//        if(requestCode==BLUETOOTH_REQUESTCODE){
//            if(resultCode==RESULT_OK){
//                openAndSearch();
//            }else{
//                Toast.makeText(this,"请先开启蓝牙",Toast.LENGTH_SHORT).show();
//                //停止扫描动画
//                stopScanAnim();
//            }
//
//        }
    }

    private void stopScanAnim() {
        BNScannerResponse.get().searchStoped();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Log.i(LOGTAG, "onRequestPermissionsResult, requestCode:" + requestCode + ",permissions:" + permissions);
//        if (REQUEST_BN_SCAN == requestCode) {
//            if (Build.VERSION_CODES.M > Build.VERSION.SDK_INT) {
//                openAndSearch();
//                return;
//            }
//
//            for (int i = 0; i < permissions.length; i++) {
//                String permission = permissions[i];
//                int grantResult = grantResults[i];
//                if (grantResult == PackageManager.PERMISSION_GRANTED) {
//                    continue;
//                } else if (grantResult == PackageManager.PERMISSION_DENIED) {
//                     showAlert("请允许相关权限");
//                    stopScanAnim();
//                    return;
//                }
//            }
//            openAndSearch();
//            return;
//        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ScanService.stopService(this);
        unregisterReceiver(mCidReceiver);
        unregisterReceiver(mScreenReceiver);
        if(mProgressDialog!=null&&mProgressDialog.isShowing()){
            mProgressDialog.dismiss();
            mProgressDialog=null;
        }
        if (EventBus.getDefault().isRegistered(this))
            EventBus.getDefault().unregister(this);
        KeyReceiver.unregister(this,mKeyReceiver);
        BNScannerRequest.get().powerOff();
    }

    private String getPermissionsTips(String permission) {
        if (Manifest.permission.CAMERA.equals(permission)) {
            return "请允许相机权限";
        }
        if (Manifest.permission.WRITE_EXTERNAL_STORAGE.equals(permission)) {
            return "请允许SDCard读写权限";
        }
        return "请允许请求的运行权限";
    }

    protected void faceAuthResult(String resultCode, String reason, String base64Image) {
        if (faceAuthResult != null) {
            Log.i(LOGTAG, "faceAuthResult, resultCode:" + resultCode + ", reason:" + reason);
            Map<String, String> map = new HashMap<>();
            map.put("resultCode", resultCode);
            map.put("reason", reason);
            map.put("base64Image", base64Image);
            faceAuthResult.success(map);
        } else {
            Log.i(LOGTAG, "faceAuthResult, faceAuthResult is null");
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        UmUtil.pageResume(this);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    @Override
    protected void onPause() {
        super.onPause();
        UmUtil.pagePause(this);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    class CIDRecive extends BroadcastReceiver{

        @Override
        public void onReceive(Context context, Intent intent) {
            String cid =intent.getStringExtra(ScanService.SCAN_CID_RESULT);
            Log.i(LOGTAG,"CIDRecive onReceiver "+cid);
            if(!TextUtils.isEmpty(cid)){
                Map<String,String>eventMap = new HashMap<>();
                eventMap.put("event","scan");
                eventMap.put("cid",cid);
                Log.i(LOGTAG,"eventShink cid .success "+cid);
                eventSink.success(eventMap);
            }
        }
    }
    ProgressDialog mProgressDialog;
    class ScreenReceiver extends BroadcastReceiver{
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if(Intent.ACTION_SCREEN_ON.equals(action)){
//                BNScannerRequest.get().reset();
                Logger.log("SCREEN ON");
                showDeviceLoading();

                ScanService.startService(MainActivity.this);
            }else if(Intent.ACTION_SCREEN_OFF.equals(action)){
                if(mProgressDialog!=null&&mProgressDialog.isShowing()){
                    mProgressDialog.dismiss();
                    mProgressDialog=null;
                }
//                ScanService.stopService(MainActivity.this);
//                Logger.log("SCREEN OFF");
//                BNScannerRequest.get().powerOff();

                MainActivity.this.finish();
            }
        }
    }

    private void showDeviceLoading() {
        if(mProgressDialog!=null&&mProgressDialog.isShowing()){
            mProgressDialog.dismiss();
            mProgressDialog=null;
        }
        mProgressDialog = new ProgressDialog(MainActivity.this);
        mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        mProgressDialog.setCancelable(false);
        mProgressDialog.setCanceledOnTouchOutside(false);
        mProgressDialog.setMessage("设备初始化...");
        mProgressDialog.show();
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mProgressDialog.dismiss();
            }
        },8000);
    }

    private void registerEventBus() {
        if (!EventBus.getDefault().isRegistered(this))
            EventBus.getDefault().register(this);
    }
}
