// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:geofence/models/geofence_model.dart';
import 'package:geofence/platform_alert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants/constants.dart';
import 'package:geofence/services/android_geofencing_client.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: Colors.lightBlue[800],
          accentColor: Colors.cyan[600],

          // Define the default font family.
          fontFamily: 'Georgia',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          )),
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  //AppLifecycleState _notification;
  //List<String> registeredGeofenceIds = [];
  //List<String> registeredGeofences = [];
  List<Geofence> availableGeofences = [];
  Geofence dropdownValue = Geofence(name: "Select a Geofence");
  String name = '';
  // TextEditingController controller = Text
  //SharedPreferences sharedPreferences;

  // String currentServer = 'http://10.0.2.2:5000/geofences/';

  // String lastEvent = 'n/a';
  // String lastRegion = 'n/a';
  // String lastLocation = 'n/a';

  String explanation = "This app needs access to your background location. "
      "For this app to work properly, go to your phone settings and allow the app "
      "to access your location in the background";

  //ReceivePort port = ReceivePort();

  static const platform = const MethodChannel("com.tradespecifix.geofencing");

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
    // IsolateNameServer.registerPortWithName(
    //     port.sendPort, 'geofencing_send_port');

    //_checkLocationPermission(context);
    _checkPermissions(context);

    getGeofences();

    // GeofencingManager.getRegisteredGeofenceIds().then((value) {
    //   setState(() {
    //     registeredGeofenceIds = value;
    //     geofenceIdsToNames();
    //   });
    // });

    //startConnectivitySubscription();

    // port.listen((dynamic data) {
    //   print('Event: $data');
    //   sendData(data);

    //   setState(() {
    //     geofenceState = data;

    //     final Map<String, dynamic> map = json.decode(geofenceState);

    //     lastEvent = map['event'];
    //     lastRegion = map['geofences'].toString();
    //     lastLocation = map['location'];

    //     timeStamp = DateTime.now();
    //   });
    // });

    //sendLogFileToServer();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   switch (state) {
  //     case AppLifecycleState.inactive:
  //       print("Inactive");
  //       setState(() {
  //         _notification = AppLifecycleState.inactive;
  //       });
  //       break;
  //     case AppLifecycleState.paused:
  //       print("Paused");
  //       setState(() {
  //         _notification = AppLifecycleState.paused;
  //       });
  //       break;
  //     case AppLifecycleState.resumed:
  //       print("Resumed");
  //       GeofencingManager.getRegisteredGeofenceIds().then((value) {
  //         setState(() {
  //           registeredGeofenceIds = value;
  //           geofenceIdsToNames();
  //         });
  //       });
  //       setState(() {
  //         _notification = AppLifecycleState.resumed;
  //       });
  //       break;
  //     case AppLifecycleState.detached:
  //       print("detachd");
  //       setState(() {
  //         _notification = AppLifecycleState.detached;
  //       });
  //       break;
  //   }
  // }

  void _checkPermissions(BuildContext context) async {
    String disclosure = "This app collects background location data to enable "
        "the geofencing feature even when the app is closed or not in use. This allows us to determine "
        "when an employee enters or leaves the perimeter of a construction site";

    var status = await Permission.location.status;
    if (status.isUndetermined) {
      bool value = await PlatformAlertDialog(
        title: "Background Location Information",
        content: disclosure,
        defaultActionText: "Ok",
        cancelActionText: "Cancel",
      ).show(context);

      if (value) {
        if (await Permission.location.request().isGranted) {
          //sendMessage();
        } else {
          await PlatformAlertDialog(
            title: "Background Location Information",
            content: explanation,
            defaultActionText: "Ok",
          ).show(context);
        }
      }
    } else {
      if (await Permission.location.request().isGranted) {
        //sendMessage();
      } else {
        await PlatformAlertDialog(
          title: "Background Location Information",
          content: explanation,
          defaultActionText: "Ok",
        ).show(context);
      }
    }
  }

  Future<void> getGeofences() async {
    try {
      String url = '$currentServer/geofences/';
      final response = await http.get(url);

      List<Geofence> geofences = geofencesFromRawJson(response.body);

      setState(() {
        availableGeofences = geofences;
        dropdownValue = availableGeofences.first;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _launchURL() async {
    const url = 'https://sites.google.com/view/geofencing-example/home';
    try {
      await launch(url);
    } catch (e) {
      print("unable to launch url");
    }
  }

  // void geofenceIdsToNames() {
  //   registeredGeofences = [];
  //   for (Geofence geofence in availableGeofences) {
  //     for (String id in registeredGeofenceIds) {
  //       if (id == geofence.id.toString()) {
  //         registeredGeofences.add(geofence.name);
  //         break;
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Geofencing Example'),
          backgroundColor: Colors.black87,
          centerTitle: true,
        ),
        body: Container(
            //color: Colors.black87,
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Container(
                  //     padding: const EdgeInsets.all(10),
                  //     child: Column(
                  //       children: [
                  //         Text(
                  //           "Event: $lastEvent",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 24),
                  //         ),
                  //         Text(
                  //           "Region: $lastRegion",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 24),
                  //         ),
                  //         Text(
                  //           "Location: $lastLocation",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.bold, fontSize: 24),
                  //         ),
                  //       ],
                  //     )),
                  // Container(
                  //   margin: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  //   child: TextField(
                  //     decoration: InputDecoration(
                  //       hintText: 'Enter your name',
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: Colors.amber, width: 2.0),
                  //         borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  //       ),
                  //     ),
                  //     onChanged: (value) {
                  //       name = value;
                  //     },
                  //   ),
                  // ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: DropdownButton<Geofence>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.white),
                      underline: Container(
                        height: 2,
                        color: Colors.amber,
                      ),
                      onChanged: (Geofence newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: availableGeofences
                          .map<DropdownMenuItem<Geofence>>((Geofence value) {
                        return DropdownMenuItem<Geofence>(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: RaisedButton(
                            child: const Text('Unregister',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            color: Colors.amber,
                            onPressed: () {
                              //handleUnregister();
                              //AndroidGeofencingClient.removeAllGeofences();
                              AndroidGeofencingClient.removeGeofenceById(
                                  dropdownValue.id.toString());
                            }),
                        padding: const EdgeInsets.only(right: 16),
                      ),
                      RaisedButton(
                          child: const Text(
                            'Register',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          color: Colors.amber,
                          onPressed: () async {
                            var status = await Permission.location.status;
                            if (status.isGranted) {
                              // if (name == "") {
                              //   await PlatformAlertDialog(
                              //     title: "Name required",
                              //     content:
                              //         "Please enter your name before registering a geofence",
                              //     defaultActionText: "Ok",
                              //   ).show(context);
                              // } else {
                              //   AndroidGeofencingClient.registerGeofence(
                              //       dropdownValue);
                              // }
                              AndroidGeofencingClient.registerGeofence(
                                  dropdownValue);
                            } else {
                              await PlatformAlertDialog(
                                title: "Background Location Information",
                                content: explanation,
                                defaultActionText: "Ok",
                              ).show(context);
                            }
                          }),
                    ],
                  ),
                  // Text("notification: $_notification"),
                  // Text('Registered Geofences: $registeredGeofences'),
                  Container(
                    color: Colors.amber,
                    margin: const EdgeInsets.all(16),
                    child: FlatButton(
                        onPressed: () {
                          _launchURL();
                        },
                        child: Text(
                          "Check the App's Privacy Policy",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                  ),
                ])));
  }
}
