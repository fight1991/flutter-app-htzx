package com.hangtian.hongtu.huatuoscan;

import android.util.Log;

public class Logger {
    public synchronized static void log(String msg){
        Log.e("LXL",msg);
    }
}
