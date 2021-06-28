package com.hangtian.hongtu;

import android.bluetooth.BluetoothDevice;

import com.hangtian.hongtu.events.BNReadDataEvent;
import com.hangtian.hongtu.events.DeviceAlarmEvent;
import com.hangtian.hongtu.events.DeviceConnectedEvent;
import com.hangtian.hongtu.events.DeviceDisConnectedEvent;
import com.hangtian.hongtu.events.DeviceFoundEvent;
import com.hangtian.hongtu.events.SearchStopedEvent;
import com.hangtian.hongtu.interfaces.IScannerResponse;

import org.greenrobot.eventbus.EventBus;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class BNScannerResponse implements IScannerResponse {
    private static BNScannerResponse instance;

    private BNScannerResponse() {

    }

    public static BNScannerResponse get() {
        if (instance == null) {
            instance = new BNScannerResponse();
        }
        return instance;
    }


    @Override
    public void newDeviceFound(List<BluetoothDevice> devices) {
        if (devices == null || devices.size() == 0) {
            return;
        }
        JSONArray jsonArray = new JSONArray();
        try {
            for (BluetoothDevice device : devices) {
                String name = device.getName();
                String address = device.getAddress();
                jsonArray.put(name+","+address);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        EventBus.getDefault().post(new DeviceFoundEvent(jsonArray.toString()));
    }

    @Override
    public void searchStoped() {
        EventBus.getDefault().post(new SearchStopedEvent());
    }

    @Override
    public void deviceConnected() {
        EventBus.getDefault().post(new DeviceConnectedEvent());
    }

    @Override
    public void deviceDisconnected() {
        EventBus.getDefault().post(new DeviceDisConnectedEvent());
    }

    /**
     *
     * @param jsonObject
     */
    @Override
    public void readDataSuccess(JSONObject jsonObject) {
        try {
            if (jsonObject != null) {
                JSONObject userObj = jsonObject.getJSONObject("User0");
                String cid  = userObj.getString("卡号");
                EventBus.getDefault().post(new BNReadDataEvent(cid));
            }
        }catch (Exception e){
            e.printStackTrace();
        }

    }

    @Override
    public void deviceAlarm(JSONObject jsonObject) {
        if (jsonObject != null)
            EventBus.getDefault().post(new DeviceAlarmEvent(jsonObject.toString()));
    }
}
