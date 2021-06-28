package com.hangtian.hongtu.ydsd;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;

public class AppHelper {
    public static boolean isApkDebugable(@NonNull Context context) {
        try {
            ApplicationInfo info = context.getApplicationInfo();
            boolean isApkDebugable = (info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
            return isApkDebugable;
        } catch (Exception e) {
        }
        return false;
    }

    public static String getMetaDataByKey(@NonNull Context context, String key, String defaultValue) {
        Bundle bundle = null;
        try {
            String packageName = context.getPackageName();
            PackageManager packageManager = context.getPackageManager();
            ApplicationInfo info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA);
            bundle = info.metaData;
        } catch (Exception e) {
        }
        String value = "";
        if (bundle != null) {
            value = bundle.getString(key, defaultValue);
        }
        return value;
    }

    public static int getVersionCode(@NonNull Context context) {

        try {
            String packageName = context.getPackageName();
            PackageManager pm = context.getPackageManager();
            PackageInfo pi = pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
            int versionCode = pi.versionCode;
            return versionCode;
        } catch (Exception e) {
        }
        return -1;
    }


}
