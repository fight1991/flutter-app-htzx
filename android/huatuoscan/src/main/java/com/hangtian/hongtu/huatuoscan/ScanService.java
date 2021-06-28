package com.hangtian.hongtu.huatuoscan;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.ILed_demo_service;
import android.os.IRf_service;
import android.os.Message;
import android.os.ServiceManager;
import android.util.Log;


import java.util.concurrent.ArrayBlockingQueue;

import me.qiaobo.eplate.SctFrameMsg;
import me.qiaobo.eplate.Tools;

import com.hangtian.hongtu.huatuoscan.verifyUtils.*;

public class ScanService extends Service {
    public static final String TAG = "ScanService";
    public static final String SCAN_CID_ACTION = "scan_cid_action";
    public static final String SCAN_CID_RESULT = "SCAN_CID_RESULT";

    private long mFirstTime = 0;
    public ILed_demo_service mLed_demo_service = null;
    public IRf_service mRf_service = null;
    byte[] mSctCache,mRFCache;
    public ArrayBlockingQueue<Byte> mRfData = new ArrayBlockingQueue<Byte>(65535);
    public RfReadThread mRfReadThread;
    public RfDealThread mRfDealThread;
    public SctReadThread mSctReadThread;
    public RfHandler mRfHandler;

    public static void startService(Context context) {
        Intent it = new Intent(context,ScanService.class);
        context.startService(it);
    }

    public static void stopService(Context context) {
        Intent it = new Intent(context,ScanService.class);
        context.stopService(it);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
       try {
           initDevices();
           new MainExtractTask().execute();
       }catch (Throwable e){}
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
       try {
           closeDevices();
       }catch (Throwable e){
           e.printStackTrace();
       }
    }

    private static  final String ACTION_NAME = "action";
    private static  final String ACTION_SCAN = "action_scan";
    public static void startScan(Context context){
        Intent it = new Intent(context,ScanService.class);
        it.putExtra(ACTION_NAME,ACTION_SCAN);
        context.startService(it);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(ACTION_SCAN.equals(intent.getStringExtra(ACTION_NAME))){
            try {
                doScan();
            }catch (Exception e){}
        }
        return super.onStartCommand(intent, flags, startId);
    }
    void doScan(){
        if(System.currentTimeMillis() - mFirstTime < 1000){
            return ;
        }
        byte[] cmdData = {(byte) 0xAA, 0x11, 0x09, 0x00, 0x06, 0x01, 0x00, 0x03, 0x11, 0x00, 0x00, 0x00, 0x00, 0x0D};//user_x first
        sctWrite(cmdData);
        mFirstTime = System.currentTimeMillis();
    }
    public class MainExtractTask extends AsyncTask<Void, Void, Integer> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            Log.i(TAG, "MainExtractTask, onPreExecute, mLoadPage");
        }

        @Override
        protected Integer doInBackground(Void... arg0) {
            try {
                openDevices();
                ThreadSleep(6000);
                byte[] mReadELEMode ={(byte) 0x7E, 0x16, 0x00, 0x01, 0x02};
                byte[] ssd = UtilsTool.getCustomMsgData((char) 0x7EFE, mReadELEMode);
                Log.i(TAG, "MainExtractTask, doInBackground, rfWrite:"+bytesToHex(ssd));
                System.out.println("rfWrite");
                rfWrite(ssd);
                ThreadSleep(1000);
            }catch (Exception e){}
            return null;
        }
        @Override
        protected void onPostExecute(Integer result) {
            //super.onPostExecute(result);
            SctVerifyStart();
            Log.i(TAG,"MainExtractTask, onPostExecute, hide loading");
        }
    }
    public void initDevices(){
        try{
            Log.i(TAG,"initDevices, 初始化Service by AIDL, start...");
            mLed_demo_service = ILed_demo_service.Stub.asInterface(ServiceManager.getService("led_demo"));
            Log.i(TAG,"initDevices, mLed_demo_service end.");
            mRf_service = IRf_service.Stub.asInterface(ServiceManager.getService("rf_demo"));
            Log.i(TAG,"initDevices, rf_demo end.");
            mLed_demo_service.sct_init();
            Log.i(TAG,"initDevices, sct_init end.");
            mRf_service.rf_init();
            Log.i(TAG,"initDevices, rf_init end.");
            mRf_service.iodev_init();
            Log.i(TAG,"initDevices, iodev_init end.");
            mRf_service.rf_setport(115200);
            Log.i(TAG,"initDevices, rf_setport 115200 end.");

            mRfReadThread = new RfReadThread();
            mRfDealThread = new RfDealThread();
            mSctReadThread = new SctReadThread();
            mRfHandler = new RfHandler();
            Log.i(TAG,"initDevices, mRfReadThread、mRfDealThread、mSctReadThread、mRfHandler, finished.");
        } catch(Exception e){
            Log.e(TAG,"initDevices failed.",e);
        }
    }
    public void ThreadSleep(long time){
        try{
            Thread.sleep(time);
        } catch(InterruptedException e){
            e.printStackTrace();
        }
    }
    public void openDevices(){
        Log.i(TAG, "openDevices start.....");
        try {
            mRf_service.iodev_outrf(1);
            ThreadSleep(100);
            mRf_service.iodev_use3p8(1);
            ThreadSleep(100);
            mRf_service.iodev_pwrrf(1);

            Log.i(TAG, "openDevices mRf_service end.");

            mLed_demo_service.sct_pwron();
            mLed_demo_service.sct_rst(); //include sct_pwron
            int s = mLed_demo_service.sct_stat();
            Log.e(TAG,"openDevices, sct_stat = " + s);
            ThreadSleep(100);

            Log.i(TAG, "openDevices mLed_demo_service end.");

            if(!mSctReadThread.isAlive()){
                mSctReadThread.start();
            }
            if(!mRfReadThread.isAlive()){
                mRfReadThread.start();
            }
            if(!mRfDealThread.isAlive()){
                mRfDealThread.start();
            }
            Log.i(TAG, "openDevices start mSctReadThread、mRfReadThread、mRfDealThread,  finished.");
        } catch (Exception e) {
            Log.e(TAG, "openDevices failed.", e);
            //e.printStackTrace();
        }
    }
    public void closeDevices(){
        Log.e(TAG, "closeDevices ....");
        try{
            mRf_service.iodev_pwrrf(0);
            ThreadSleep(100);
            mRf_service.iodev_use3p8(0);
            ThreadSleep(100);
            mRf_service.iodev_outrf(0);

            Log.i(TAG, "closeDevices mRf_service, end.");

            mLed_demo_service.sct_pwrdown();

            Log.i(TAG, "closeDevices mLed_demo_service, end.");
        } catch(Exception e){
            Log.e(TAG,"closeDevices failed.",e);
        }
        if(mSctReadThread.isAlive()){
            mSctReadThread.interrupt();
        }
        if(mRfReadThread.isAlive()){
            mRfReadThread.interrupt();
        }
        if(mRfDealThread.isAlive()){
            mRfDealThread.interrupt();
        }
        Log.i(TAG,"closeDevices, mSctReadThread、mRfReadThread、mRfDealThread, close finish.");
    }
    public void SctVerifyStart(){
        byte[] requestRandData = {(byte) 0xAA, 0x31, 0x01, 0x00, 0x01, 0x31};
        sctWrite(requestRandData);
        Log.i(TAG, "SctVerifyStart, sctWrite:"+bytesToHex(requestRandData));
    }
    private byte[] encodeVerifyData(){
        int len = 32 + 64 + 521;
        byte[] verifyData = new byte[len];
        byte[] sourceData = new byte[32];
        //
        VerifyData.signDataStruct.Rm = System.currentTimeMillis();
        System.arraycopy(UtilsTool.getUuid().getBytes(), 0, VerifyData.signDataStruct.Sn, 0, 8);
        System.arraycopy(UtilsTool.toLE_u8v(0), 0, VerifyData.signDataStruct.Nu, 0, 8);
        //
        System.arraycopy(UtilsTool.toLE_u8v(VerifyData.signDataStruct.Rm), 0, sourceData, 0, 8);
        System.arraycopy(VerifyData.signDataStruct.Rs, 0, sourceData, 8, 8);
        System.arraycopy(VerifyData.signDataStruct.Sn, 0, sourceData, 16, 8);
        System.arraycopy(VerifyData.signDataStruct.Nu, 0, sourceData, 24, 8);
        byte[] signedData = SM2.sign(VerifyData.default_prikey, sourceData);
        System.arraycopy(sourceData, 0, verifyData, 0, 32);
        System.arraycopy(signedData, 0, verifyData, 32, 64);
        System.arraycopy(VerifyData.default_auth_x509, 0, verifyData, 96, 521);
        Log.i(TAG,"encodeVerifyData， encodeVerifyData == ok");
        return verifyData;
    }
    public int sctWrite(byte[] data){
        Log.e(TAG, "sctWrite, data:"+bytesToHex(data));
        int tLen = -1;
        try{
            if(data.length < 600){
                UtilsTool.printHEXforBytes(data, "Cards sct write:s ");
            }
            tLen = mLed_demo_service.sct_writeData(data);
            Log.i(TAG,"sctWrite, sctWrite, mLed_demo_service sct_writeData tLen = " + tLen);
            ThreadSleep(200);
        } catch(Exception e){
            Log.e(TAG,"sctWrite failed.",e);
        }
        return tLen;
    }
    public int rfWrite(byte[] data){
        Log.e(TAG, "rfWrite, data:"+bytesToHex(data));
        int tLen = -1;
        try{
            UtilsTool.printHEXforBytes(data, " rf write: ");
            tLen = mRf_service.rf_writeData(data);
            Log.i(TAG,"rfWrite, finish. mRf_service.rf_writeDatat Len = " + tLen);
        } catch(Exception e){
            Log.e(TAG,"rfWrite failed.", e);
        }
        return tLen;
    }
    public static String bytesToHex(byte[] data){
        if(data == null){
            return null;
        }
        StringBuilder builder = new StringBuilder();
        for(int i = 0; i < data.length; i++){
            builder.append(String.format("%02X", data[i]) + " " );
        }
        return builder.toString();
    }

    public class SctReadThread extends Thread {
        public SctReadThread(){
            super();
        }
        @Override
        public void run() {
            //super.run();
            Log.i(TAG,"SctReadThread start....");
            while (true){
                try{
                    mSctCache =mLed_demo_service.sct_read();
                    //UtilsTool.printHEXforBytes(mSctCache, "Cards sct Rece:");
                    Log.i(TAG,"SctReadThread sct_read 读到数据");
                    printHEXforBytes(mSctCache);
                    int len = mSctCache.length;
                    if(len < 6 || len > 1500){
                        Log.e(TAG, "SctReadThread, mSctCache length error-");
                        continue;
                    }
                    if(mSctCache[len-1] != SctData.get_sct_xor(mSctCache, len -1)){
                        Log.e(TAG, "SctReadThread, mSctCache xor error-");
                        continue;
                    }
                    Log.i(TAG, "SctReadThread, 数据正确, 开始解析，SctData rec_SctData decode");
                    SctData rec_SctData = new SctData();
                    rec_SctData.decode(mSctCache);
                    Log.i(TAG, "SctReadThread, 解析到的数据，mType=" + rec_SctData.mType);
                    Message msg = Message.obtain();
                    Bundle bundle = new Bundle();
                    switch ((int)rec_SctData.mType){
                        case SctData.FRAME_TYPE_CONFIG_ACK: //0x02:
                            Log.e(TAG, "SctReadThread, 0x02 配置应答帧");
                            //
                            if(rec_SctData.mCmd == 0x06 && rec_SctData.mContent[1] == 0x00){
                                byte[] mStartSingleRead = {(byte) 0x7E, (byte) 0x80, 0x00, 0x04, 0x01, (byte) 0x00, 0x01, 0x00}; //user_x second
                                byte[] ssd = UtilsTool.getCustomMsgData((char) 0x7E00, mStartSingleRead);
                                System.out.println("rfWrite");
                                Log.i(TAG, "SctReadThread, rfWrite : "+bytesToHex(ssd));
                                rfWrite(ssd);
                            }
                            //
                            msg.what = SctData.FRAME_TYPE_CONFIG_ACK;
                            bundle.putByteArray("sctconfig",mSctCache);
                            msg.setData(bundle);
                            break;
                        case SctData.FRAME_TYPE_AUTH_ACK: //0x04:
                            Log.e(TAG, "SctReadThread, 0x04 认证响应帧");
                            // Verify 2
                            if(rec_SctData.mCmd == 0x01) {
                                Log.i(TAG, "1 handleMessage mContent length = " + rec_SctData.mContent.length);
                                Log.i(TAG, "SctReadThread, mCmd = 0x01, mContent : " + bytesToHex(rec_SctData.mContent));
                                System.arraycopy(rec_SctData.mContent, 1, VerifyData.signDataStruct.Rs, 0, 8);
                                SctData sctData = new SctData();
                                sctData.mHeader = (byte) 0xAA;
                                sctData.mType = 0x03;
                                sctData.mVersion = 0x01;
                                sctData.mLen = 618;
                                sctData.mContent = new byte[618];
                                sctData.mCmd = 0x02;
                                sctData.mContent[0] = 0x02;
                                System.arraycopy(encodeVerifyData(), 0, sctData.mContent, 1, 617);
                                byte[] mData = sctData.encode();
                                //2 second write sct
                                Log.i(TAG, "SctReadThread, sctWrite: " + bytesToHex(mData));
                                int len2 = sctWrite(mData);
                                Log.i("richard", "write len  = " + len2);
                                //mIsOpenedSctReady = true;
                                ThreadSleep(1000);
                            } else if(rec_SctData.mCmd == 0x02){
                                //
                            }
                            msg.what = SctData.FRAME_TYPE_AUTH_ACK;
                            bundle.putByte("mCmd", rec_SctData.mCmd);
                            bundle.putByteArray("mContent", rec_SctData.mContent);
                            msg.setData(bundle);
                            break;
                        case SctData.FRAME_TYPE_RFID_INFO: //0x05:
                            Log.e(TAG, "SctReadThread, 0x05 识读信息帧");
                            // start read
//                            if(rec_SctData.mCmd == 0x02){
//                                msg.what = SctData.FRAME_TYPE_RFID_INFO;
//                                //bundle.putByteArray("sctconfig", mSctCache);
//                                bundle.putSerializable("sctData", rec_SctData);
//                                msg.setData(bundle);
//                            } else
                            if(rec_SctData.mCmd == 0x03){// 识读
                                // read :
                                int user_x = 0;
                                Log.e(TAG,"userx == " + user_x);
                                if(user_x == 0){
                                    msg.what = SctData.FRAME_TYPE_RFID_INFO;
                                    bundle.putSerializable("sctData", rec_SctData);
                                    msg.setData(bundle);
                                }
//                                else {
//                                    byte[] cmdData = {(byte) 0xAA, (byte) 0xA1, 0x01, 0x00, (byte) (0xE0 | user_x), 0x00}; //user_x third
//                                    cmdData[5] = SctData.get_sct_xor(cmdData, 5);
//                                    sctWrite(cmdData);
//                                }
                            }
                            //
                            break;
                        case SctData.FRAME_TYPE_TRANS_DATA_ACK: //0x07:
                            Log.e(TAG, "SctReadThread, 0x07 ");
                            msg.what = SctData.FRAME_TYPE_TRANS_DATA_ACK;
                            bundle.putByteArray("sctconfig",mSctCache);
                            msg.setData(bundle);
                            break;
                        case SctData.FRAME_TYPE_ERROR:  //0x08:
                            Log.e(TAG, "SctReadThread, 0x08 ");
                            msg.what = SctData.FRAME_TYPE_ERROR;
                            break;
                    }
                    Log.i(TAG,"SctReadThread, 消息发给 mRfHandler.sendMessage(msg) :"+msg.what);
                    mRfHandler.sendMessage(msg);
                }catch (Exception e){
                    Log.e(TAG,"SctReadThread, 读取消息失败 ",e);
                }
                if(Thread.currentThread().isInterrupted()){
                    Log.e(TAG,"SctReadThread isInterrupted");
                    break;
                }
            } // end while(true)
            Log.e(TAG,"SctReadThread end while(true)");
        }
    }
    public class RfReadThread extends Thread{

        public RfReadThread(){
            super();
        }

        @Override
        public void run() {
            // TODO Auto-generated method stub
            //super.run();
            Log.i(TAG, "RfReadThread, start...");
            while(true){

                try{
                    mRFCache = mRf_service.rf_read();

                    if(mRFCache != null){
                        Log.e(TAG, "RfReadThread, 读取到信息 :" + bytesToHex(mRFCache));
                        Log.i(TAG, "RfReadThread, 2 rf Rece length :" + mRFCache.length);
                        UtilsTool.printHEXforBytes(mRFCache,"2 rf Rece:");
                        for(int i = 0; i < mRFCache.length; i++){
                            mRfData.put(mRFCache[i]);
                        }
                        if(!mRfDealThread.isAlive()){
                            mRfDealThread.start();
                        }
                    } else {
                        Thread.sleep(1);
                    }
                } catch(Exception e){
                    Log.e(TAG,"RfReadThread failed.",e);
                }
                if(Thread.currentThread().isInterrupted()){
                    Log.e(TAG,"RfReadThread isInterrupted.");
                    break;
                }
            }
            Log.e(TAG,"RfReadThread exit!");
        }


    }
    public class RfDealThread extends Thread{
        public RfDealThread(){
            super();
        }

        @Override
        public void run() {
            Log.i(TAG,"RfDealThread start....");
            while(true){
                try{
                    byte hb = mRfData.take();
                    if(hb != 0x48){
                        continue;
                    }
                    RfMessage rfMessage = new RfMessage();
                    byte tb = mRfData.take();

                    if(hb == 0x48 && tb == 0x54){
                        rfMessage.mUuid[0] = hb;
                        rfMessage.mUuid[1] = tb;
                        for(int i = 2; i < 8; i++){
                            rfMessage.mUuid[i] = mRfData.take();
                        }
                        rfMessage.mVersion = mRfData.take();
                        rfMessage.mType = (char) (((mRfData.take() & 0x00ff)<<8) |(0x00ff & mRfData.take()));
                        rfMessage.mLength = (int)((mRfData.take()&0x000000ff) <<24
                                | (mRfData.take()&0x000000ff) <<16
                                | (mRfData.take()&0x000000ff) <<8
                                | (mRfData.take()&0x000000ff));
                        System.out.println("rfMessage.mLength: " + rfMessage.mLength);
                        rfMessage.mID = (int)((mRfData.take()&0x000000ff) <<24
                                | (mRfData.take()&0x000000ff) <<16
                                | (mRfData.take()&0x000000ff) <<8
                                | (mRfData.take()&0x000000ff));
                        if(rfMessage.mLength < 0 || rfMessage.mLength > 65530){
                            continue;
                        }
                        rfMessage.mData = new byte[rfMessage.mLength];
                        for(int j = 0; j< rfMessage.mLength; j++){
                            rfMessage.mData[j] = mRfData.take();
                        }
                        rfMessage.mCrc16[0] = mRfData.take();
                        rfMessage.mCrc16[1] = mRfData.take();
                        byte[] MsgData = rfMessage.toBytes();
                        char crc16 = UtilsTool.uhf_crc16_ccitt_tab(MsgData,MsgData.length);
                        if(((byte) ((crc16>>8) & 0x00FF) != rfMessage.mCrc16[0]) && ((byte) (crc16 & 0x00FF) != rfMessage.mCrc16[1])){
                            System.out.println("crc16 checked error!");
                            continue;
                        }
                    } else {
                        continue;
                    }
                    Log.i(TAG,"RfDealThread, rfMessage.mType: " + (int)rfMessage.mType +", 0x"+Integer.toHexString((int)rfMessage.mType));
                    if(rfMessage.mType == RfMessage.SYS_PARA_SET){
                        Message message = Message.obtain();
                        message.what = 0;
                        Bundle bundleData = new Bundle();
                        bundleData.putByteArray("param_bytes",rfMessage.mData);
                        message.setData(bundleData);
                        mRfHandler.sendMessage(message);
                        Log.e(TAG,"RfDealThread........RfMessage.SYS_PARA_SET");
                    }
                } catch(InterruptedException e){
                    Log.e(TAG, "mRfData.take 超时", e);
                }
            }
        }
    }
    public class RfHandler extends Handler {

        @Override
        public void handleMessage(Message msg) {
            Log.i(TAG, "RfHandler, handleMessage,msg.what:"+msg.what);
            // TODO Auto-generated method stub
            //super.handleMessage(msg);
//            try {
            Bundle bundleData = msg.getData();
            switch (msg.what) {
                case 0:
                    Log.i(TAG, "RfHandler, 无处理:"+msg.what);
                    byte[] paramData = bundleData.getByteArray("param_bytes");
                    UtilsTool.printHEXforBytes(paramData, "paramData:");
                    System.out.println();
                    break;
                case 2:
                    Log.i(TAG, "RfHandler, 无处理:"+msg.what);
                    break;
                case 4:
                    Log.i(TAG, "RfHandler, 无处理:"+msg.what);
                    break;
                case 5:

                    SctData sctData = (SctData)bundleData.getSerializable("sctData");
                    if(sctData != null){
                        if(sctData.mContent[1] != 0){
                            Logger.log("====>error:"+sctData.mContent[1]);
                        } else {
                        }
                        String txt = UtilsTool.bytesToHex(sctData.mContent, 2);
//                        mEtData.setText(txt);


                        Log.e(TAG, "RfHandler, handleMessage,说明结果来了:"+txt);
                        Log.e(TAG, "RfHandler, handleMessage,说明结果来了:"+txt);
                        Log.i(TAG, "RfHandler, sctData:"+sctData);

                        SctFrameMsg sctFrameMsg = new SctFrameMsg();
//                         sctFrameMsg.decode((byte) 2, sctData.mContent);
                         sctFrameMsg.decode(sctData.mVersion, sctData.mContent);
                        Log.i(TAG,"解析结果===>:" + sctFrameMsg.toString());
                        if(sctFrameMsg.getData("8801")!=null){
                            String cid = sctFrameMsg.getData("8801").getValue();;
                            Log.i(TAG,"8801===>:" + cid);
                            Intent it = new Intent(SCAN_CID_ACTION);
                            it.putExtra(SCAN_CID_RESULT,cid);
                            ScanService.this.sendBroadcast(it);
                        }else{
                            Log.i(TAG,"8801===>:null");
                        }
                    }
                    break;
                case 7:
                    Log.i(TAG, "RfHandler, 无处理:"+msg.what);
                case 8:
                    Log.i(TAG, "RfHandler, 读取报错。。。。。无处理:"+msg.what);
                    break;
            }
            /*}catch (UnsupportedEncodingException e){
                e.printStackTrace();
            }*/
        }

    }

    public static void printHEXforBytes(byte[] data){
        if(data == null){
            Log.i(TAG,"printHEXforBytes data = null");
            return;
        }
        StringBuilder builder = new StringBuilder();
        for(int i = 0; i < data.length; i++){
            builder.append(String.format("%02X", data[i]) + " " );
        }
        Log.i(TAG,"printHEXforBytes data:"+builder.toString());
    }
}
