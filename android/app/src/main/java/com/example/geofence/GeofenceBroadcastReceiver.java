package com.example.geofence;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import com.google.android.gms.location.GeofencingEvent;
import android.util.Log;
import com.google.android.gms.location.GeofenceStatusCodes;
import com.google.android.gms.location.Geofence;
import java.util.List;
import androidx.work.WorkRequest;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.Data;
import androidx.work.BackoffPolicy;
import java.util.concurrent.TimeUnit;
import java.time.*;
import java.time.format.DateTimeFormatter;
import androidx.work.Constraints;
import androidx.work.NetworkType;
import android.widget.Toast;

public class GeofenceBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = "Broadcast Receiver";

    @Override
    public void onReceive(Context context, Intent intent){
        
        GeofencingEvent geofencingEvent = GeofencingEvent.fromIntent(intent);
        // Log.i(TAG, geofencingEvent.toString());
        
        if (geofencingEvent.hasError()){
            String errorMessage = GeofenceStatusCodes.getStatusCodeString(geofencingEvent.getErrorCode());
            Log.e(TAG, errorMessage);
            return;
        }

        // Get the transition type.
        int geofenceTransition = geofencingEvent.getGeofenceTransition();

        // Test that the reported transition was of interest.
        if (geofenceTransition == Geofence.GEOFENCE_TRANSITION_ENTER ||
                geofenceTransition == Geofence.GEOFENCE_TRANSITION_EXIT) {

            List<Geofence> triggeringGeofences = geofencingEvent.getTriggeringGeofences();
            LocalDateTime time = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String timeString = time.format(formatter);

            Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();

            Log.i(TAG, triggeringGeofences.get(0).toString());

            String ts = "geofence: "+triggeringGeofences.get(0).toString()+", "+
                    "time: "+timeString+", event"+geofenceTransition;

            WorkRequest geofencingWorkRequest =
                new OneTimeWorkRequest.Builder(GeofencingWorker.class)
                    .setInputData(
                        new Data.Builder()
                            .putString("geofence", triggeringGeofences.get(0).getRequestId()  )
                            .putInt("transition", geofenceTransition)
                            .putString("time", timeString)
                            .build()
                    ).setBackoffCriteria(
                        BackoffPolicy.LINEAR,
                        OneTimeWorkRequest.MIN_BACKOFF_MILLIS,
                        TimeUnit.MILLISECONDS)
                    .setConstraints(constraints)
                    .build();
            
            WorkManager.getInstance(context).enqueue(geofencingWorkRequest);
            try{
                Toast.makeText(context, ts, Toast.LENGTH_LONG).show();
            } catch (Exception e){
                Log.e(TAG, e.toString());
            }
           
        } else {
            Log.e(TAG, "error");
        }
    }
}