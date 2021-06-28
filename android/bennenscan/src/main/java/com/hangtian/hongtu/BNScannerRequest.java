package com.hangtian.hongtu;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.Process;
import android.util.Log;

import com.bellonplugin.HandSetControlImpl;
import com.bellonplugin.parm.ReadType;
import com.hangtian.hongtu.interfaces.IScannerRequest;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class BNScannerRequest implements IScannerRequest {
    private static final String TAG= "BNScanner";
    private static BNScannerRequest mInstance;
    public static synchronized BNScannerRequest get(){
        if(mInstance==null){
            mInstance = new BNScannerRequest();
        }
        return mInstance;
    }

    HandSetControlImpl handSetControl;
    Handler mHandler = new Handler(Looper.getMainLooper()){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            Log.i(TAG, "handleMessAge:"+msg.what);
            switch (msg.what) {
                case 0:
                    Log.i(TAG, "可以拿数据");
                    try{
                        JSONObject jsonObj = handSetControl.getTagVehicleInfo();
                        if(jsonObj!=null){
                            BNScannerResponse.get().readDataSuccess(jsonObj);
                            Log.e(TAG, jsonObj.toString());
                        }
                    }catch (Exception e){
                        Log.e(TAG,"读取信息异常："+e);
                    }

                    break;

                case 1:
                    Log.i(TAG, "蓝牙连接成功:"+msg.toString());
                    BNScannerResponse.get().deviceConnected();
                    break;
                case 2:
                    Log.i(TAG, "蓝牙断开");
                    BNScannerResponse.get().deviceDisconnected();
                    break;
                case 3:
                    Log.i(TAG, "设备报警信息");
                   try {
                       BNScannerResponse.get().deviceAlarm(handSetControl.getDeviceAlarm());
                   }catch (Exception e){
                       Log.i(TAG, "读取设备报警信息异常："+e);
                   }
                    break;
                case 0xAA:
                    //左短按
                case 0xBA:
                    //右短按
                    break;
                case 0xAC:
                    //左松开
                case 0xBC:
                    //右松开
                    try {
                        boolean isSuccess = handSetControl.stopReadVehicle();
                        handSetControl.doSingleReadVehicle();
                        Log.i(TAG,"松开停止读:" + isSuccess);
                    }catch (Exception e){
                        e.printStackTrace();
                    }
                    break;
                case 0xAB:
                    //左边长按
                case 0xBB:
                     //右边长按
                    try {
                        boolean isSuccess = handSetControl.startReadVehicle();
                        Log.i(TAG,"长按开始读:" + isSuccess);
                    }catch (Exception e){
                        e.printStackTrace();
                    }
                    break;

                default:
                    break;


            }
        }
    };
    private BNScannerRequest(){
        handSetControl = new HandSetControlImpl();
         pownerOn();
        //handSetControl.getDeviceSN();
    }

    public void reset(){
        Log.i(TAG,"powerReset");
        if(handSetControl==null){
            handSetControl = new HandSetControlImpl();
        }
        pownerOn();
    }

    final List<BluetoothDevice> mDevicesList = new ArrayList<>();
    public void checkDeviceState(){
        try {
            JSONObject jsonObject = handSetControl.deviceStateCheck();
            if(jsonObject!=null){
                Log.i(TAG,jsonObject.toString());
            }else{
                Log.e(TAG,"checkDeviceState Error");
            }
        }catch (Exception e){
            Log.e(TAG,"checkDeviceState Error:"+e);
        }
    }

    public String getDeviceId(){
       try {
           String deviceID = handSetControl.getDeviceSN();
           Log.i(TAG,"devceID:"+deviceID);
           return deviceID;
       }catch (Exception e){
           return null;
       }
    }

    static long lastReadTime = 0;
    public boolean singleRead(){
      if(Math.abs(System.currentTimeMillis()-lastReadTime)<1000){
          return false;
      }
      lastReadTime = System.currentTimeMillis();
      try {
          Log.i(TAG,"singleRead");
          return handSetControl.startReadVehicle(new ReadType((long)2),920125,20,2,1);
      }catch (Exception e){
          e.printStackTrace();
          handSetControl = null;
          mInstance = null;
      }
      return  false;
    }

    public void pownerOn(){
        try {
            boolean openSrialPort = handSetControl.openSrialPort();


            Log.i(TAG,"打开串口:"+openSrialPort);
            handSetControl.RFPowerOn();
            Log.i(TAG,"设备上电:");
            handSetControl.receiveSerial();
            Log.i(TAG,"启动接收线程");
//            deviceRunType = handSetControl.getDeviceRunType();
//            Log.i(TAG,"设备运行状态2:"+deviceRunType);
            handSetControl.setHandler(mHandler);
//        handSetControl.setReadSpeed(100);

            Log.i(TAG,"powerOn");
        }catch (Exception e){
            e.printStackTrace();
            handSetControl=null;
            mInstance = null;
        }
    }

    public void powerOff(){
     try {
         handSetControl.RFPowerOff();
     }catch (Exception e){
         e.printStackTrace();

     } handSetControl = null;
        mInstance = null;
        Log.i(TAG,"powerOff");
        android.os.Process.killProcess(android.os.Process.myPid());    //获取PID
        Process.killProcess(Process.myPid());
        System.exit(0);

    }

//    public void searchDevice(Activity activity){
//        reset();
//        handSetControl.scanBLE(activity);
//        Log.i(TAG,"搜索蓝牙设备");
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                int a = 0;
//                mDevicesList.clear();
//                Log.i(TAG,"搜索蓝牙设备");
//                while (a < 10) {
//                    Log.i(TAG,"....handSetControl.getBLEDevice()....");
//                    final List<BluetoothDevice> list = handSetControl.getBLEDevice();
//                    Log.e(TAG,"listSize="+list.size());
//                    for (int i = 0; i < list.size(); i++) {
//                        if(!mDevicesList.contains(list.get(i))){
//                            mDevicesList.add(list.get(i));
//                            Log.i(TAG,"new device:"+list.get(i).getName()
//                                    +","+list.get(i).getAddress());
//                            BNScannerResponse.get().newDeviceFound(mDevicesList);
//                        }
//                    }
//                    try {
//                        Thread.sleep(1000);
//                    } catch (InterruptedException e) {
//                        e.printStackTrace();
//                    }
//                    a++;
//                }
//                //show searchDeviceUi
//                BNScannerResponse.get().searchStoped();
//            }
//        }).start();
//    }
//
//    public void connectDevice(Context context,BluetoothDevice device){
//        Log.i(TAG,"connect device("+device.getName()+")");
//        handSetControl.connectBLE(context.getApplicationContext(),device);
//    }
//    public boolean connectDevice(Context context,String deviceAddress){
//        Log.i(TAG,"connect device("+deviceAddress+")");
//        BluetoothDevice device = null;
//        for(BluetoothDevice temp:mDevicesList){
//            if(temp.getAddress().equals(deviceAddress)){
//                device = temp;
//            }
//            break;
//        }
//        if(device!=null){
//            Log.i(TAG,"handSetControl("+device.getAddress()+")");
//            handSetControl.connectBLE(context.getApplicationContext(),device);
//            return  true;
//        }
//        return false;
//
//    }
//
//    public boolean disConnectDevice(Context context,String deviceAddress){
//        BluetoothDevice device = null;
//        for(BluetoothDevice temp:mDevicesList){
//            if(temp.getAddress().equals(deviceAddress));
//            device = temp;
//            break;
//        }
//        if(device!=null){
//            Log.i(TAG,"breakBLE,device:"+device.getAddress());
//            handSetControl.breakBLE();
//            return  true;
//        }
//        return false;
//    }
//    public void disConnectDevice(Context context,BluetoothDevice device){
//        handSetControl.breakBLE(context,device);
//    }
}
