package com.hangtian.hongtu.interfaces;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Context;

public interface IScannerRequest {
    /**
     * 搜索蓝牙设备
     * @param activity
     */
//    void searchDevice(Activity activity);

    /**
     * 连接蓝牙设备
     * @param context
     * @param deviceAddress
     */
//    boolean connectDevice(Context context, String deviceAddress);

    /**
     * 断开蓝牙设备
     * @param context
     * @param deviceAddress
     */
//    boolean disConnectDevice(Context context,String deviceAddress);

    /**
     * 设备状态检查
     */
    void checkDeviceState();

    /**
     * 获取deviceId
     */
    String getDeviceId();
}
