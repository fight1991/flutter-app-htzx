package com.hangtian.hongtu.ydsd;

import android.content.Context;
import android.util.Log;

import androidx.multidex.MultiDex;

import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;

import io.flutter.app.FlutterApplication;

public class AppApplication extends FlutterApplication {

    private static final String TAG = "AppApplication";

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(base);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        //友盟统计
        initUMConfig();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }

    private void initUMConfig() {
        Log.i(TAG, "initUMConfig");
        UMConfigure.init(this, "5ec2562fdbc2ec078b5be984", "ht_def", UMConfigure.DEVICE_TYPE_PHONE, "");
        UMConfigure.setLogEnabled(false);

        // 选用LEGACY_AUTO页面采集模式
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.LEGACY_MANUAL);
        // 支持在子进程中统计自定义事件
        UMConfigure.setProcessEvent(true);
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO);
    }
}
