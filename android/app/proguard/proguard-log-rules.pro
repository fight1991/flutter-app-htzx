#keep class
-keep interface com.taobao.tao.log.ITLogController{*;}
-keep class com.taobao.tao.log.upload.*{*;}
-keep class com.taobao.tao.log.message.*{*;}
-keep class com.taobao.tao.log.LogLevel{*;}
-keep class com.taobao.tao.log.TLog{*;}
-keep class com.taobao.tao.log.TLogConstant{*;}
-keep class com.taobao.tao.log.TLogController{*;}
-keep class com.taobao.tao.log.TLogInitializer{public *;}
-keep class com.taobao.tao.log.TLogUtils{public *;}
-keep class com.taobao.tao.log.TLogNative{*;}
-keep class com.taobao.tao.log.TLogNative$*{*;}
-keep class com.taobao.tao.log.CommandDataCenter{*;}
-keep class com.taobao.tao.log.task.PullTask{*;}
-keep class com.taobao.tao.log.task.UploadFileTask{*;}
-keep class com.taobao.tao.log.upload.LogFileUploadManager{public *;}
-keep class com.taobao.tao.log.monitor.**{*;}
#兼容godeye
-keep class com.taobao.tao.log.godeye.core.module.*{*;}
-keep class com.taobao.tao.log.godeye.GodeyeInitializer{*;}
-keep class com.taobao.tao.log.godeye.GodeyeConfig{*;}
-keep class com.taobao.tao.log.godeye.core.control.Godeye{*;}
-keep interface com.taobao.tao.log.godeye.core.GodEyeAppListener{*;}
-keep interface com.taobao.tao.log.godeye.core.GodEyeReponse{*;}
-keep interface com.taobao.tao.log.godeye.api.file.FileUploadListener{*;}
-keep public class * extends com.taobao.android.tlog.protocol.model.request.base.FileInfo{*;}
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod