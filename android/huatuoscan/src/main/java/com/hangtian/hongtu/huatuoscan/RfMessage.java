package com.hangtian.hongtu.huatuoscan;

import android.util.Log;

import java.io.Serializable;

public class RfMessage implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 2L;
    public static final String TAG = "RfMessage";
    
    public static final char SYS_PARA_SET = 0x7EFE;
    public static final char ROM_UPDATE = 0x7EFD;
    public static final char RECE_TAG_MSG = 0x7EFC;
    public static final char PARAMETER_EPC = 0x7E60;
    public static final char PARAMETER_TID = 0x7E61;
    public static final char INT_MSG_CMD = 0x7E00;
    
    public byte[] mUuid = new byte[8];
    public byte mVersion;
    public char mType;
    public int mLength;
    public int mID;
    public byte[] mData;
    public byte[] mCrc16 = new byte[2];
    /*public char mParaType;
    public char mParaLength;
    public byte mAnten;
    public char mU8vLength = 0;
    public byte[] mData;*/

    public void decode(byte[] data) {
        if(data == null){
            return;
        }
        if(data[0] != 0x48){
            return;
        }
        int tlen = data.length;
        int msgCounts = 0;
        Log.e(TAG, "data length = " + tlen);

        //do{
        System.arraycopy(data, 0, mUuid, 0, 8);
        mVersion = data[8];
        mType =(char) (((data[9] & 0x00ff)<<8) |(0x00ff & data[10]));
        mLength = (int) ((data[11]&0x000000ff) <<24
                | (data[12]&0x000000ff) <<16
                | (data[13]&0x000000ff) <<8
                | (data[14]&0x000000ff));
        mID = (int) ((data[15]&0x000000ff) <<24
                | (data[16]&0x000000ff) <<16
                | (data[17]&0x000000ff) <<8
                | (data[18]&0x000000ff));
        if(mLength > 0 && mLength < tlen){
            mData = new byte[mLength];
            if(mLength <= (tlen -19)){
                System.arraycopy(data, 19, mData, 0, mLength);
            } else {
                //System.arraycopy(data, 19, mData, 0, tlen -19);
                mData = null;
                Log.e("rfrece", "mData = null.");
            }
        }
        //tlen = tlen -(21 + mLength);
        //}while(tlen/(21+mLength) >= 1);
        /*if(tlen > 25){
            mParaType = (char) (((data[19] & 0x00ff)<<8) |(0x00ff & data[20]));
            mParaLength = (char) (((data[21] & 0x00ff)<<8) |(0x00ff & data[22]));
            mAnten = data[23];
            mU8vLength = (char) (((data[24] & 0x00ff)<<8) |(0x00ff & data[25]));
        }
        Log.e(TAG, "data mU8vLength length = " + mU8vLength);
        if(tlen > (mU8vLength + 25)){
            mData = new byte[mU8vLength];
            System.arraycopy(data, 26, mData, 0, mU8vLength);
        }*/
    }
    public byte[] toBytes(){
        byte[] retData = new byte[mLength+19];
        System.arraycopy(mUuid, 0, retData, 0, mUuid.length);
        byte[] byte1 = new byte[1];
        byte1[0] = mVersion;
        System.arraycopy(byte1, 0, retData, 8, 1);
        byte[] byte2 = new byte[2];
        byte2[0] = (byte) (mType >> 8);
        byte2[1] = (byte) (mType & 0xff);
        System.arraycopy(byte2, 0, retData, 9, 2);
        
        System.arraycopy(intToBytes(mLength), 0, retData, 11, 4);
        System.arraycopy(intToBytes(mID), 0, retData, 15, 4);
        System.arraycopy(mData, 0, retData, 19, mData.length);
        return retData;
        
    }
    public static byte[] intToBytes(int n){
        byte[] b = new byte[4];
        for(int i = 0; i<4; i++){
            b[i] = (byte)(n >>(24 - i*8));
        }
        return b;
    }

}
