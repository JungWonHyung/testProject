package com.mapzen.tangram;

import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by cheolgi on 2018. 1. 4..
 */

public class RatioCore {
    private AppCompatActivity activity;

    public RatioCore(AppCompatActivity activity) {
        this.activity = activity;

        nativeRatioConfiguration_init();
    }

    // Utility
    public static final long DIFF_2001_1970_MS = 978307200000L;

    public long getCurrentTimeMillisFrom2001() {
        long from1970 = System.currentTimeMillis();

        return from1970 - DIFF_2001_1970_MS;
    }

    public double getCurrentTimeSecFrom2001() {
        long from1970 = System.currentTimeMillis();

        return (double)(from1970 - DIFF_2001_1970_MS) / 1000.0;
    }

    /*
     * System (File I/O)
     */

    public String vmSystem_getDocFilePath() {
        return activity.getApplicationInfo().dataDir;
    }
    
    /*
     * UpdateNotifier
     */

    private double scheduledTime = 0.0;

    private Timer timer;

    private Runnable timerRoutine = new Runnable() {
        public void run() {
            scheduledTime += 1.0;

            // Android는 fixed rate으로 동작시키는 것이 가능하므로 skew를 처리하는
            // 별도의 작업은 두지 않는다.
            if(Math.abs(getCurrentTimeSecFrom2001() - scheduledTime) < 0.2) {
                nativeUpdateNotifier_triggered(scheduledTime);
            }
        }
    };

    private TimerTask timerTask;

    private void makeNewTimerTask() {
        timerTask = new TimerTask() {
                @Override
                public void run() {
                    activity.runOnUiThread(timerRoutine);
                }
            };
    }

    public void vmUpdateNotifier_timer_init() {
        timer = new Timer();
        makeNewTimerTask();
        
        long currentTime1970ms = System.currentTimeMillis();
        scheduledTime = getCurrentTimeSecFrom2001();

        timer.scheduleAtFixedRate(timerTask, 1000, 1000);

        nativeUpdateNotifier_triggered(scheduledTime);
    }

    public void vmUpdateNotifier_timer_finish() {
        timer.cancel();
    }

    public void vmUpdateNotifier_timer_updateOffsetBaseTime(double baseTime) {
        if( timer != null) {
            timer.cancel();
        }

        timer = new Timer();
        makeNewTimerTask();
        
        double current = getCurrentTimeSecFrom2001();
        double diffFloorFrom_0_1 = Math.floor(baseTime - (current - 0.1));
        
        baseTime -= diffFloorFrom_0_1;
        Log.d("Ratio", "Update: diff " + (baseTime - (current - 0.1)));
        Log.d("Ratio", "Update: diff floor" + diffFloorFrom_0_1);
        Log.d("Ratio", "Update: diff abs" + Math.abs(current - baseTime));

        
        if(Math.abs(current - baseTime) <= 0.1) {
            baseTime += 1.0;
            timer.scheduleAtFixedRate(timerTask, (long)((baseTime - current) * 1000), 1000);
            
            nativeUpdateNotifier_triggered(baseTime - 1.0);
            Log.d("Ratio", "Update: temp trigger " + baseTime);
        } else {
            timer.scheduleAtFixedRate(timerTask, (long)((baseTime - current) * 1000), 1000);
            Log.d("Ratio", "Update: temp update " + baseTime + ", " + current);
        }

        scheduledTime = baseTime - 1.0;
        
    }

    protected native void nativeUpdateNotifier_triggered(double scheduledTime);


    /*
     * RatioConfiguration
     */

    protected native void nativeRatioConfiguration_init();


    static {
        System.loadLibrary("c++_shared");
        System.loadLibrary("tangram");
    }
}
