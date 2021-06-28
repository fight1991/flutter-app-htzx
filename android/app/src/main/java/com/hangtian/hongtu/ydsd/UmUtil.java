package com.hangtian.hongtu.ydsd;

import android.app.Activity;
import android.content.Context;

import com.umeng.analytics.MobclickAgent;



public class UmUtil {
    public static  void pageResume(Activity context){
        MobclickAgent.onResume(context);
    }
    public  static  void pagePause(Activity context){
        MobclickAgent.onPause(context);
    }
}
