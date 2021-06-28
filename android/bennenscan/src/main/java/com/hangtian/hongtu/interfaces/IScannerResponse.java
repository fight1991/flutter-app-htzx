package com.hangtian.hongtu.interfaces;

import android.bluetooth.BluetoothDevice;

import org.json.JSONObject;

import java.util.List;

public interface IScannerResponse {

    /**
     * 搜索到新的设备
     */
    void newDeviceFound(List<BluetoothDevice> devices);

    /**
     * 停止搜索
     */
    void searchStoped();

    /**
     * 蓝牙连接成功
     */
    void deviceConnected();

    /**
     * 蓝牙断开
     */
    void deviceDisconnected();

    /**
     * 读取数据成功
     */
    void readDataSuccess(JSONObject jsonObject);

    /**
     * 设备报警信息
     * @param jsonObject
     */
    void deviceAlarm(JSONObject jsonObject);
}
