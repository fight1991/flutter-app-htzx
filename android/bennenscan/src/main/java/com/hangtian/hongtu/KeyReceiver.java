package com.hangtian.hongtu;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.nfc.Tag;
import android.util.Log;
import android.view.KeyEvent;

import com.bellonplugin.parm.ReadType;

import org.json.JSONObject;

public class KeyReceiver  extends BroadcastReceiver {
    static final String TAG = "KeyReceiver";
    @Override
    public void onReceive(Context context, Intent intent) {
        int keyCode = intent.getIntExtra("keyCode", 0);
        if (keyCode == 0) {
            keyCode = intent.getIntExtra("keycode", 0);
        }
        boolean keyDown = intent.getBooleanExtra("keydown", false);
        if (keyDown) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_F1:
                    Log.i(TAG,"F1Down");
                    break;
                case KeyEvent.KEYCODE_F2:
                    Log.i(TAG,"F2Down");
                    break;
                case KeyEvent.KEYCODE_F3:
                    Log.i(TAG,"F3Down");
                    break;
                case KeyEvent.KEYCODE_F4:
                    Log.i(TAG,"F4Down");
                    break;
                case KeyEvent.KEYCODE_F5:
                        Log.i(TAG,"F5Down");
                    break;
            }
        }else {
            switch (keyCode) {
                case KeyEvent.KEYCODE_F1:
                    Log.i(TAG,"F1up");
                    break;
                case KeyEvent.KEYCODE_F2:
                    Log.i(TAG,"F2up");
                    break;
                case KeyEvent.KEYCODE_F3:
                    boolean singleRead = BNScannerRequest.get().singleRead();
                    Log.i(TAG,"F3up===========singleRead============》"+singleRead);

                    break;
                case KeyEvent.KEYCODE_F4:
                    Log.i("info","F4up");
                    break;
                case KeyEvent.KEYCODE_F5:
                    singleRead = BNScannerRequest.get().singleRead();
                    Log.i(TAG,"F5up===========singleRead============》"+singleRead);
                    break;
            }

        }
    }

    public static  KeyReceiver register(Activity activity) {
        KeyReceiver keyReceiver = new KeyReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction("android.rfid.FUN_KEY");
        filter.addAction("android.intent.action.FUN_KEY");
        activity.registerReceiver(keyReceiver , filter);
        return  keyReceiver;
    }

    public static void unregister(Activity activity, KeyReceiver keyReceiver){
        activity.unregisterReceiver(keyReceiver);
    }
}
