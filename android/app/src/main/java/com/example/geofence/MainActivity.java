package com.example.geofence;

import io.flutter.embedding.android.FlutterActivity;
import com.google.android.gms.location.GeofencingClient;
import com.google.android.gms.location.LocationServices;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;
import android.util.Log;
import com.google.android.gms.location.GeofencingRequest;
import com.google.android.gms.location.Geofence;
import java.util.ArrayList;
import android.app.PendingIntent;
import android.content.Intent;
import java.util.HashMap;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.OnFailureListener;

//import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.tradespecifix.geofencing";
    private static final String TAG = "Main Activity";

    GeofencingClient geofencingClient;
    ArrayList<Geofence> geofenceList;
    PendingIntent geofencePendingIntent;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if(call.method.equals("startGeofencingClient")){
                        geofencingClient = LocationServices.getGeofencingClient(this);
                        HashMap<String, Object> map = call.arguments();
                        // String username = map.get("username").toString();
                        // register to shared preferences
                        addGeofenceToList(map);
                        registerGeofences();
                        Log.i(TAG, geofenceList.get(0).getRequestId());
                        Log.i(TAG, geofencingClient.toString());
                        result.success("geofencing client started");
                    }else if (call.method.equals("removeAllGeofences")){
                        geofencingClient = LocationServices.getGeofencingClient(this);
                        removeAllGeofences();
                        result.success("geofences were successfully removed");
                    }else if (call.method.equals("removeGeofenceById")){
                        geofencingClient = LocationServices.getGeofencingClient(this);
                        HashMap<String, Object> map = call.arguments();
                        removeGeofencesByRequestId(map);
                        result.success("geofence was successfully removed");
                    }
                }
            );
    }

    private void addGeofenceToList(HashMap<String, Object> map){
        geofenceList = new ArrayList<Geofence>();
        geofenceList.add(new Geofence.Builder()
            .setRequestId(map.get("name").toString() ) 
            .setCircularRegion(
                new Double(map.get("latitude").toString()),
                new Double(map.get("longitude").toString()),
                new Float(map.get("radius").toString())   
            )
            .setExpirationDuration(1000 * 1000 * 1000)
            .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER |
                Geofence.GEOFENCE_TRANSITION_EXIT)
            .build());
    }

    private void removeGeofencesByRequestId(HashMap<String, Object> map){
        ArrayList<String> list = new ArrayList<>();
        list.add(map.get("requestId").toString());
        geofencingClient.removeGeofences(list)
        .addOnSuccessListener(this, new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                Log.i(TAG, "successfully remove geofence");
            }
        })
        .addOnFailureListener(this, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                // Failed to add geofences
                // ...
                Log.i(TAG, e.toString());
            }
        });

    }

    private void registerGeofences(){
        geofencingClient.addGeofences(getGeofencingRequest(), getGeofencePendingIntent())
        .addOnSuccessListener(this, new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                Log.i(TAG, "successfully added geofences");
            }
        })
        .addOnFailureListener(this, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                // Failed to add geofences
                // ...
                Log.i(TAG, e.toString());
            }
        });
    }

    private void removeAllGeofences(){
        geofencingClient.removeGeofences(getGeofencePendingIntent())
        .addOnSuccessListener(this, new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                Log.i(TAG, "Successfully removed geofences");
            }
        })
        .addOnFailureListener(this, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                //Failed to remove geofences
                Log.i(TAG, e.toString());
            }
        });
    }

    private GeofencingRequest getGeofencingRequest() {
        GeofencingRequest.Builder builder = new GeofencingRequest.Builder();
        builder.setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER);
        builder.addGeofences(geofenceList);
        return builder.build();
    }

    private PendingIntent getGeofencePendingIntent() {
        // Reuse the PendingIntent if we already have it.
        if (geofencePendingIntent != null) {
            return geofencePendingIntent;
        }
        Intent intent = new Intent(this, GeofenceBroadcastReceiver.class);
        // We use FLAG_UPDATE_CURRENT so that we get the same pending intent back when
        // calling addGeofences() and removeGeofences().
        geofencePendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.
                FLAG_UPDATE_CURRENT);
        return geofencePendingIntent;
    }
}