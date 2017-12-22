package com.mapzen.tangram;


import android.os.Handler;
import android.os.Looper;

/**
 * Created by cheolgi on 2017. 12. 21..
 */

public class NativeMainRunnable implements Runnable {
    Handler mainHandler;

    long nativePtr;

    public static native void initialize();
    
    public static void runInMainThread(long nativePtr) {

        NativeMainRunnable runnable = new NativeMainRunnable(nativePtr);
        
        runnable.mainHandler.post(runnable);
    }

    public NativeMainRunnable(long nativePtr) {
        this.nativePtr = nativePtr;
        mainHandler = new Handler(Looper.getMainLooper());
    }

    private native void nativeRun(long ptr);

    @Override
    public void run() {
        nativeRun(nativePtr);
    }
}
