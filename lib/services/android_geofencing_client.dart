import 'package:flutter/services.dart';
import 'package:geofence/models/geofence_model.dart';

class AndroidGeofencingClient {
  static const platform = const MethodChannel("com.tradespecifix.geofencing");

  static Future<String> registerGeofence(Geofence geofence) async {
    final String result = await platform.invokeMethod('startGeofencingClient', {
      'name': geofence.id,
      'latitude': geofence.lat,
      'longitude': geofence.lng,
      'radius': geofence.radius
    });

    return result;
  }

  static Future<String> removeAllGeofences() async {
    final String result = await platform.invokeMethod("removeAllGeofences");
    return result;
  }

  static Future<String> removeGeofenceById(String reqId) async {
    final String result =
        await platform.invokeMethod("removeGeofenceById", {"requestId": reqId});
  }
}
