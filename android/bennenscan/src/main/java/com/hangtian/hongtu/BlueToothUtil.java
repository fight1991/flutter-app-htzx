package com.hangtian.hongtu;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;

public class BlueToothUtil {
    /**
     * 判断手机是否支持蓝牙
     * @return
     */
    public static boolean isBlueToothEnable(){
        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter == null) {
           return  false;
        }
        return true;
    }

    public static boolean openBlueTooth(Activity act,int requestCode){
        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            act.startActivityForResult(enableBtIntent, requestCode);
            return false;
        }
        return  true;

    }


}
