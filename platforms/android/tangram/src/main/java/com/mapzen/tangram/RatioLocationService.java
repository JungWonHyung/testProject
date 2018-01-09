package com.mapzen.tangram;

import android.Manifest;
import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.IBinder;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import java.lang.Exception;

/**
* Created by rapsealk on 2018. 1. 8..
*/
class RatioLocationService extends Service {

    private AppCompatActivity activity;

    public RatioLocationService(AppCompatActivity activity) {
        this.activity = activity;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
       Log.d("LocationService", "onStartCommand init service")
       if (ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
           Toast.makeText(applicationContext, "Updating location requires permission.", Toast.LENGTH_SHORT).show();
       }

       FusedLocationProviderClient mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
       mFusedLocationClient.lastLocation
               .addOnSuccessListener { (Location location) ->
                   if (location != null) {
                       // TODO("handle location")
                       Log.d("LocationService", "OnSucceess: $location");
                       val event = LocationUpdateEvent(location, System.currentTimeMillis());
                       stopSelf();
                   } else throw new Exception();
               }
               .addOnFailureListener { exception: Exception ->
                        exception.printStackTrace();
           stopSelf();
               }
       return super.onStartCommand(intent, flags, startId)
   }

    @Override
    void onDestroy() {
        Log.d("LocationService", "onDestroy()");
        super.onDestroy();
   }
}
