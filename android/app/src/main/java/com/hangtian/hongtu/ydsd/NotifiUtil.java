package com.hangtian.hongtu.ydsd;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;

public class NotifiUtil {
    private static final String TAG = "NotifiUtil";

    public static void showNotif(Context context,String title,String text){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.i(TAG, "buildNotification 11111 ");
            NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            // 通知渠道的id
            String id = "514";
            // 用户可以看到的通知渠道的名字.
            CharSequence name = title;
            // 用户可以看到的通知渠道的描述
            String description = text;
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(id, name, importance);
            // 配置通知渠道的属性
            mChannel.setDescription(description);
            // 设置通知出现时的闪灯（如果 android 设备支持的话）
            mChannel.enableLights(true);
            mChannel.setLightColor(Color.WHITE);
            // 设置通知出现时的震动（如果 android 设备支持的话）
            mChannel.enableVibration(true);
            mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            //最后在notificationmanager中创建该通知渠道
            mNotificationManager.createNotificationChannel(mChannel);
            Log.i(TAG, "buildNotification 9999999 ");
        }
    }
}
