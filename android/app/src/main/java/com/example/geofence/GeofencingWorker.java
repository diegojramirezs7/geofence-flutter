package com.example.geofence;
import android.content.Context;
import androidx.work.WorkerParameters;
import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.ListenableWorker.Result;
import android.util.Log;
import androidx.work.Data;
import java.time.*;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import org.json.JSONObject;
import java.util.HashMap;
import com.google.android.gms.location.Geofence;

public class GeofencingWorker extends Worker{
    public GeofencingWorker(@NonNull Context context, @NonNull WorkerParameters params) {
       super(context, params);
    }

    private static final String TAG = "Worker";

    @Override
    public Result doWork(){
        // do something
        String geofenceString = getInputData().getString("geofence");
        int transition = getInputData().getInt("transition", -1);
        String time = getInputData().getString("time");
        
        RequestQueue queue = Volley.newRequestQueue(getApplicationContext());
        String currentServer = "https://safe-falls-49683.herokuapp.com";

        String url = "https://safe-falls-49683.herokuapp.com/events/";
        
        String eventString;

        if (transition == Geofence.GEOFENCE_TRANSITION_ENTER){
            eventString = "enter";
        } else if (transition == Geofence.GEOFENCE_TRANSITION_EXIT){
            eventString = "exit";
        } else {
            eventString = "dwell";
        }

        HashMap<String, String> map = new HashMap<String, String>();

        Log.i(TAG, geofenceString);
        
        map.put("event", eventString);
        map.put("geofence", geofenceString);
        map.put("time", time);

        JSONObject json = new JSONObject(map);
        Log.i(TAG, json.toString());

        JsonObjectRequest req = new JsonObjectRequest(Request.Method.POST, url, json, 
            new Response.Listener<JSONObject>() {
                @Override
                public void onResponse(JSONObject response) {
                    //textView.setText("Response: " + response.toString());
                    Log.i(TAG, response.toString());
                }
            }, 
            new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {
                    // TODO: Handle error
                    Log.e(TAG, error.toString());
                }
            }
        );

        queue.add(req);
        
        // Log.i(TAG, time.toString()); 
        // Log.i(TAG, geofenceString);
        // Log.i(TAG, Integer.toString(transition));
        
        
        return Result.success();
    }
}
