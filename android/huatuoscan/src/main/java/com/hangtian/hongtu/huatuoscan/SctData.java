package com.hangtian.hongtu.huatuoscan;

import java.io.Serializable;


/**
 * 主控CPU与安全模块之间的通信数据帧
 * CPU and Security module communication data frame
 * @author richard.H.T.S.
 *
 */
public class SctData implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 4L;
    // FRAME TYPE
    public static final byte FRAME_TYPE_NONE =0x00;  //0 无
    public static final byte FRAME_TYPE_CONFIG_REQ =0x01;  // 1 配置帧
    public static final byte FRAME_TYPE_CONFIG_ACK =0x02;  // 2 配置应答帧
    public static final byte FRAME_TYPE_AUTH_REQ =0x03;  // 3 认证帧
    public static final byte FRAME_TYPE_AUTH_ACK =0x04;  // 4 认证响应帧
    public static final byte FRAME_TYPE_RFID_INFO =0x05;  // 5 识读信息帧
    public static final byte FRAME_TYPE_TRANS_DATA =0x06;  // 6 
    public static final byte FRAME_TYPE_TRANS_DATA_ACK =0x07;  // 7 
    public static final byte FRAME_TYPE_ERROR =0x08;  // 8

    
    public byte mHeader;
    public byte mType;
    public byte mVersion = 0x01; //always 
    public short mLen = 1;
    public byte mCmd;
    public byte[] mContent = null;
    public byte mXor;
    
    public SctData(){
        
    }

    public SctData(byte header, byte type, short len, byte[] content){
        this.mHeader = header;
        this.mType = type;
        this.mLen = len;
        this.mContent = content;
    }

    
    private int getDataSize() {
        return mLen + 5;
    }

    /**
     * 
     * @param r
     * @return
     */
    public static byte[] toLE_u8v(long r){
        byte[] buff = new byte[8];
        for(int i = 0; i < 8; i++){
            int offset = i * 8;
            buff[i] = (byte)((r >> offset) & 0xff);
        }
        return buff;
    }

    /**
     * 
     * @param data
     * @return
     */
    public static long toLong_ltb(byte[] data){
        long value = 0;
        for(int i = 0; i < 8; i++){
            int shif = i << 3;
            value |= ((long)0xff<<shif) & ((long)data[i] << shif);
        }
        return value;
    }
    public static byte get_sct_xor(byte[] content, int offset){
        int i = 0;
        byte xor = 0;
        for(i = 1; i < offset; i++){
            xor ^= content[i];
        }
        return xor;
    }
    public byte[] encode() {
        byte[] result = new byte[getDataSize()];
        result[0] = mHeader;
        result[1] = (byte) (mType << 4 | mVersion);
        result[2] = (byte) (mLen & 0xff);
        result[3] = (byte) (mLen >> 8);
        result[4] = mCmd;
        int offset = 5;
        if(mContent != null){
            System.arraycopy(mContent, 0, result, offset - 1, mLen);
            offset = offset + mLen - 1;
        }

        mXor = get_sct_xor(result, offset);
        result[offset] = mXor;
        
        return result;
    }

    public void decode(byte[] data) {
        if(data == null){
            return;
        }
        mHeader = data[0];
        mType = (byte) ((data[1] >>4)&0x0f);
        mVersion =  (byte) (data[1] & 0x0f);
        mLen = (short)(((data[3]&0x00ff)<<8)|(0x00ff & data[2]));
        mCmd = data[4];
        int offset = 4;
        if(mLen > 0){
            mContent = new byte[mLen];
            System.arraycopy(data, offset, mContent, 0, mLen);
        }
        offset = offset + mLen;
        mXor = data[offset];

    }
}
