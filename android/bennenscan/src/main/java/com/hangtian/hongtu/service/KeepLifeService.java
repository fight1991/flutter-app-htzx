package com.hangtian.hongtu.service;


import android.app.ActivityManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.Process;
import android.text.TextUtils;
import android.util.Log;


import com.bellonplugin.HandSetControlImpl;
import com.hangtian.hongtu.BNScannerRequest;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.List;

/**
 * Created by SH on 2019/4/22.
 */

public class KeepLifeService extends Service {

    ActivityManager mActivityManager;
    String mPackName;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i("KeepLifiService", " KeepLifeService isOnCreated");
        mActivityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        mPackName = getPackageName();
        String process = getProcessName();

        boolean isRun = isRunningProcess(mActivityManager,mPackName);
        Log.i("KeepLifiService", String.format("onCreate:%s %s pid=%d uid=%d isRun=%s",mPackName,process, Process.myPid(), Process.myUid(),isRun));

        if (!isRun){
            Intent intent = getPackageManager().getLaunchIntentForPackage(mPackName);
            if(intent!=null){
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
//                MyUtil.openSrialPort();
//                MyUtil.mserialPort.power3v3off();
//                HandSetControlImpl.RFPowerOff();
                BNScannerRequest.get().powerOff();
                Log.e("KeepLifiService", "=================强杀下电=============");
            }

        }

    }

    //获取当前进程名称
    public static String getProcessName(){
        try {
            File file = new File("/proc/"+ Process.myPid()+"/"+"cmdline");
            BufferedReader mBufferedReader = new BufferedReader(new FileReader(file));
            String processName = mBufferedReader.readLine().trim();
            mBufferedReader.close();
            return processName;

        } catch (Exception e) {
            e.printStackTrace();
        }   return null;
    }

    //进程是否存活
    public static boolean isRunningProcess(ActivityManager manager, String processName){
        if (manager == null) {
            return false;
        }
            List<ActivityManager.RunningAppProcessInfo> runnings = manager.getRunningAppProcesses();
        if (runnings != null){
            for (ActivityManager.RunningAppProcessInfo info :runnings){
                if (TextUtils.equals(info.processName,processName)){
                    return true;
                }
            }
        }
        return false;

    }
}


