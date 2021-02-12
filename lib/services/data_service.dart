// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:connectivity/connectivity.dart';
// import 'package:geofence/constants/constants.dart';
// import 'package:geofence/models/geofence_model.dart';
// import 'package:geofencing/geofencing.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class DataService {
//   StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   final List<GeofenceEvent> triggers = <GeofenceEvent>[
//     GeofenceEvent.enter,
//     GeofenceEvent.dwell,
//     GeofenceEvent.exit
//   ];

//   final AndroidGeofencingSettings androidSettings = AndroidGeofencingSettings(
//       initialTrigger: <GeofenceEvent>[
//         GeofenceEvent.enter,
//         GeofenceEvent.exit,
//         GeofenceEvent.dwell
//       ],
//       loiteringDelay: 1000 * 15);

//   Future<void> sendData(String dataString) async {
//     try {
//       //check if there's connection, if yes, send event, else, write to file

//       var connectivityResult = await (Connectivity().checkConnectivity());
//       if (connectivityResult == ConnectivityResult.mobile ||
//           connectivityResult == ConnectivityResult.wifi) {
//         // I am connected to either mobile or wifi network
//         //String url = 'https://safe-falls-49683.herokuapp.com/geofence/';

//         Map<String, dynamic> data = json.decode(dataString);

//         String eventType;
//         if (data['event'] == GeofenceEvent.enter.toString()) {
//           eventType = "enter";
//         } else if (data['event'] == GeofenceEvent.exit.toString()) {
//           eventType = "exit";
//         } else {
//           eventType = "dwell";
//         }

//         String geofenceId = data['geofences'].first;
//         String callbackTime = data['time'];

//         //String url = 'http://10.0.2.2:5000/events/';
//         String url = '$currentServer/events/';
//         var response;
//         int counter = 0;

//         do {
//           response = await http.post(url, body: {
//             'event': eventType,
//             'time': callbackTime,
//             'geofence': geofenceId
//           });
//           counter++;
//         } while (response.statusCode != 200 || counter < 5);
//         print(response.body);
//       } else {
//         // write to file
//         print("no internet");
//         writeEventLog(dataString);
//       }
//     } catch (e) {
//       //throw e;
//     }
//   }

//   Future<List<Geofence>> getGeofences() async {
//     try {
//       String url = '$currentServer/geofences/';
//       final response = await http.get(url);

//       List<Geofence> geofences = geofencesFromRawJson(response.body);

//       return geofences;
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   Future<void> startConnectivitySubscription() async {
//     _connectivitySubscription = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) async {
//       if (result == ConnectivityResult.mobile ||
//           result == ConnectivityResult.wifi) {
//         try {
//           //getGeofences();
//           String logFile = await readLogFile();
//           if (logFile != "") {
//             sendLogFileToServer();
//           }
//         } catch (e) {
//           //print(e.toString());
//         }
//       }
//     });
//   }

//   Future<void> sendLogFileToServer() async {
//     try {
//       // read, send, delete contents
//       String contents = await readLogFile();
//       if (contents != "") {
//         List data = json.decode(contents);
//         String url = '$currentServer/events/';
//         String eventType;
//         String geofenceId;
//         var response;

//         for (Map<String, dynamic> log in data) {
//           if (log['event'] == GeofenceEvent.enter.toString()) {
//             eventType = "enter";
//           } else if (log['event'] == GeofenceEvent.exit.toString()) {
//             eventType = "exit";
//           } else {
//             eventType = "dwell";
//           }

//           geofenceId = log['geofences'].first;
//           response = await http.post(url, body: {
//             'event': eventType,
//             'time': log['time'],
//             'geofence': geofenceId
//           });
//         }
//         if (response.statusCode == 200) {
//           final file = await _localFile;
//           return file.writeAsString("");
//         }
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     return File('$path/eventLog.txt');
//   }

//   Future<File> writeEventLog(String dataString) async {
//     try {
//       final file = await _localFile;
//       String logFileContent = await readLogFile();
//       Map<String, dynamic> data = json.decode(dataString);

//       String newString;

//       if (logFileContent == "") {
//         newString = "[$dataString]";

//         print(newString);
//       } else {
//         List logFileJson = json.decode(logFileContent);
//         logFileJson.add(data);
//         newString = json.encode(logFileJson);
//         print(newString);
//       }
//       return file.writeAsString(newString, mode: FileMode.write);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future<String> readLogFile() async {
//     try {
//       final file = await _localFile;

//       // Read the file.
//       String contents = await file.readAsString();

//       print(contents);

//       return contents;
//     } catch (e) {
//       // If encountering an error, return 0.

//       print("inside catch statement of readlog file: ${e.toString()}");
//       return "";
//     }
//   }

//   static void callback(List<String> ids, Location l, GeofenceEvent e) async {
//     print('Fences: $ids Location $l Event: $e');
//     final SendPort send =
//         IsolateNameServer.lookupPortByName('geofencing_send_port');

//     var timeStamp = DateTime.now();

//     Map<String, dynamic> map = {
//       "event": e.toString(),
//       "geofences": ids,
//       "location": l.toString(),
//       "time": timeStamp.toString()
//     };

//     String data = json.encode(map);

//     send?.send(data);
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     print('Initializing...');
//     await GeofencingManager.initialize();

//     print('Initialization done');
//   }

//   // void registerHandler() {
//   //   GeofencingManager.registerGeofence(
//   //           GeofenceRegion(dropdownValue.id.toString(), dropdownValue.lat,
//   //               dropdownValue.lng, dropdownValue.radius * 1.0, triggers,
//   //               androidSettings: androidSettings),
//   //           callback)
//   //       .then((_) {
//   //     GeofencingManager.getRegisteredGeofenceIds().then((value) {
//   //       setState(() {
//   //         registeredGeofenceIds = value;
//   //         geofenceIdsToNames();
//   //       });
//   //     });
//   //   });
//   // }

//   // void handleUnregister() {
//   //   GeofencingManager.removeGeofenceById(dropdownValue.id.toString()).then((_) {
//   //     GeofencingManager.getRegisteredGeofenceIds().then((value) {
//   //       setState(() {
//   //         registeredGeofenceIds = value;
//   //         geofenceIdsToNames();
//   //       });
//   //     });
//   //   });
//   // }

// }
