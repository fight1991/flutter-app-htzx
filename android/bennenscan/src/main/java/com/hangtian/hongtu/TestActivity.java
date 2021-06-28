package com.hangtian.hongtu;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import com.hangtian.hongtu.bennenscan.R;

public class TestActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bennentest_activity);
        request();
        findViews();
    }

    private void findViews() {
        findViewById(R.id.btn_search).setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
//                        BNScannerRequest.get().searchDevice(TestActivity.this);
                    }
                }
        );
        findViewById(R.id.btn_connect).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                if(BNScannerRequest.get().mDevicesList.size()>0)
//                    BNScannerRequest.get().connectDevice(TestActivity.this, BNScannerRequest.get().mDevicesList.get(0));
//                else
//                    Toast.makeText(TestActivity.this,"没有设备",Toast.LENGTH_SHORT).show();
            }
        });
        findViewById(R.id.btn_disconnect).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                if(BNScannerRequest.get().mDevicesList.size()>0)
//                    BNScannerRequest.get().disConnectDevice(TestActivity.this, BNScannerRequest.get().mDevicesList.get(0));
//                else
//                    Toast.makeText(TestActivity.this,"没有设备",Toast.LENGTH_SHORT).show();
            }
        });
        findViewById(R.id.btn_deviceid).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               BNScannerRequest.get().getDeviceId();
            }
        });
        findViewById(R.id.btn_devicestate).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               BNScannerRequest.get().checkDeviceState();
            }
        });
    }

    private void request() {
        //动态申请权限
        if (Build.VERSION.SDK_INT >= 23) {
            int REQUEST_CODE_PERMISSION_STORAGE = 100;
            String[] permissions = {
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
            };

            for (String str : permissions) {
                if (this.checkSelfPermission(str) != PackageManager.PERMISSION_GRANTED) {
                    this.requestPermissions(permissions, REQUEST_CODE_PERMISSION_STORAGE);
                    return;
                }
            }
        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode,  String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

}
