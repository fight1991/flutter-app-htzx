package com.hangtian.hongtu.huatuoscan.verifyUtils;

import android.util.Log;

import org.bouncycastle.crypto.AsymmetricCipherKeyPair;
import org.bouncycastle.crypto.generators.ECKeyPairGenerator;
import org.bouncycastle.crypto.params.ECDomainParameters;
import org.bouncycastle.crypto.params.ECKeyGenerationParameters;
import org.bouncycastle.crypto.params.ECPrivateKeyParameters;
import org.bouncycastle.crypto.params.ECPublicKeyParameters;
import org.bouncycastle.math.ec.ECCurve;
import org.bouncycastle.math.ec.ECFieldElement;
import org.bouncycastle.math.ec.ECFieldElement.Fp;
import org.bouncycastle.math.ec.ECPoint;

import java.math.BigInteger;
import java.security.SecureRandom;

public class SM2 {

    public static String[] ecc_param = {
        "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF",
        "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC",
        "28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93",
        "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123",
        "32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7",
        "BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0"
    };
    
    public static SM2 Instance(){
        return new SM2();
    }
    
    public final BigInteger ecc_p;
    public final BigInteger ecc_a;
    public final BigInteger ecc_b;
    public final BigInteger ecc_n;
    public final BigInteger ecc_gx;
    public final BigInteger ecc_gy;
    public final ECCurve ecc_curve;
    public final ECPoint ecc_point_g;
    public final ECDomainParameters ecc_bc_spec;
    public final ECKeyPairGenerator ecc_key_pair_generator;
    public final ECFieldElement ecc_gx_fieldelement;
    public final ECFieldElement ecc_gy_fieldelement;
    
    public SM2(){
        this.ecc_p = new BigInteger(ecc_param[0], 16);
        this.ecc_a = new BigInteger(ecc_param[1], 16);
        this.ecc_b = new BigInteger(ecc_param[2], 16);
        this.ecc_n = new BigInteger(ecc_param[3], 16);
        this.ecc_gx = new BigInteger(ecc_param[4], 16);
        this.ecc_gy = new BigInteger(ecc_param[5], 16);
        
        this.ecc_gx_fieldelement = new Fp(this.ecc_p, this.ecc_gx);
        this.ecc_gy_fieldelement = new Fp(this.ecc_p, this.ecc_gy);
        
        this.ecc_curve = new ECCurve.Fp(this.ecc_p, this.ecc_a, this.ecc_b);
        this.ecc_point_g = new ECPoint.Fp(this.ecc_curve, this.ecc_gx_fieldelement, this.ecc_gy_fieldelement);
        
        this.ecc_bc_spec = new ECDomainParameters(this.ecc_curve, this.ecc_point_g, this.ecc_n);
        
        ECKeyGenerationParameters ecc_ecgenparam;
        ecc_ecgenparam = new ECKeyGenerationParameters(this.ecc_bc_spec, new SecureRandom());
        
        this.ecc_key_pair_generator = new ECKeyPairGenerator();
        this.ecc_key_pair_generator.init(ecc_ecgenparam);
    }
    
    public void sm2Sign(byte[] md, BigInteger userD, ECPoint userKey, SM2Result sm2Result){
        BigInteger e = new BigInteger(1, md);
        BigInteger k = null;
        ECPoint kp = null;
        BigInteger r = null;
        BigInteger s = null;
        do{
            do{
                AsymmetricCipherKeyPair keypair = ecc_key_pair_generator.generateKeyPair();
                ECPrivateKeyParameters ecpriv = (ECPrivateKeyParameters)keypair.getPrivate();
                ECPublicKeyParameters ecpub = (ECPublicKeyParameters)keypair.getPublic();
                k = ecpriv.getD();
                kp = ecpub.getQ();
                
                r = e.add(kp.getX().toBigInteger());
                r = r.mod(ecc_n);
            } while(r.equals(BigInteger.ZERO) || r.add(k).equals(ecc_n));
            BigInteger da_1 = userD.add(BigInteger.ONE);
            da_1 = da_1.modInverse(ecc_n);
            // s
            s = r.multiply(userD);
            s = k.subtract(s).mod(ecc_n);
            s = da_1.multiply(s).mod(ecc_n);
        } while(s.equals(BigInteger.ZERO));
        
        sm2Result.r = r;
        sm2Result.s = s;
    }
    
    public static byte[] sign(byte[] privateKey, byte[] sourceData) {
        if(privateKey == null || privateKey.length == 0){
            return null;
        }
        if(sourceData == null || sourceData.length == 0){
            return null;
        }
        
        SM2 sm2 = SM2.Instance();
        BigInteger userD = new BigInteger(privateKey);
        ECPoint userKey = sm2.ecc_point_g.multiply(userD);
        
        byte[] md = new byte[32];
        Log.e("SM2","sourceData len = " + sourceData.length);
        for(int i1 = 0; i1 < 32; i1++){ //
            md[i1] = sourceData[31-i1];
        }
        
        SM2Result sm2Result = new SM2Result();
        sm2.sm2Sign(md, userD, userKey, sm2Result);
        
        byte[] signedData = new byte[64];
        byte[] rr = byteConvert32Bytes(sm2Result.r);
        byte[] ss = byteConvert32Bytes(sm2Result.s);
        for(int i2 = 0; i2 < 32; i2++){
            signedData[i2] = rr[31-i2];
            signedData[32+i2] = ss[31-i2];
        }
        
        return signedData;
    }
    
    public static byte[] byteConvert32Bytes(BigInteger n){
        byte tmpd[] = (byte[])null;
        if(n == null){
            return null;
        }
        Log.e("SM2", "byteConvert32Bytes n.length = " + n.toByteArray().length);
        if(n.toByteArray().length == 33){
            tmpd = new byte[32];
            System.arraycopy(n.toByteArray(), 1, tmpd, 0, 32);
        } else if(n.toByteArray().length == 32){
            tmpd = n.toByteArray();
        } else {
            tmpd = new byte[32];
            for(int i = 0; i < 32 - n.toByteArray().length; i++){
                tmpd[i] = 0;
            }
            System.arraycopy(n.toByteArray(), 0, tmpd, 32 - n.toByteArray().length, n.toByteArray().length);
        }
        return tmpd;
    }
}
