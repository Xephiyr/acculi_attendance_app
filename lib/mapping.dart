import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

//import 'package:acculi_attendance_app/get_attendance.dart';

final Set<Marker> markerss = {};
LatLng ret;

Location location = new Location();

Future<void> setAttendance() async {
  DateTime now = DateTime.now();

  var pos;
  pos = await location.getLocation();
  var day = now.day;
  var month = now.month;

  var db = FirebaseFirestore.instance;
  final QuerySnapshot query = await db
      .collection('position')
      .where('Email', isEqualTo: global.globalSessionData.email)
      .orderBy('Time')
      .limitToLast(1)
      .get();
  if (query.size != 0) {
    var snapshot = query.docs[0];
    DateTime uTime = snapshot.data()['Time'];
    var uDay = uTime.day;
    var uMonth = uTime.month;
    if (day != uDay || month != uMonth) {
      //add attendance
      print('First attendance for today');
      return db
          .collection("position")
          .add({
            'Email': global.globalSessionData.email,
            'Name': global.globalSessionData.name,
            'Location': GeoPoint(pos.latitude, pos.longitude),
            'Time': now,
          })
          .then((value) => print("NoError in adding attendance"))
          .catchError((error) => print("Error"));
    }
  }
}

class MapCaller extends StatefulWidget {
  @override
  _MapCaller createState() => _MapCaller();
}

class _MapCaller extends State<MapCaller> {
  LatLng _initialcameraposition = LatLng(12.9159355, 77.5207615);

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  getLocationPermission() async {
    print('Getting Location Permission here');
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    print(_permissionGranted.toString());
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      print(_permissionGranted.toString());
      if (_permissionGranted != PermissionStatus.granted) {
        print(_permissionGranted.toString());
        return;
      }
    }
  }

  @override
  void initState() {
    getLocationPermission();
    setAttendance();
    markerss.clear();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GoogleMapController controller;

  var pos;
  var current;

  void _onMapCreated(GoogleMapController _cntlr) async {
    controller = _cntlr;

    pos = await location.getLocation();
    /*double dist;
    var inl, v;*/
    await controller.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(global.globalSessionData.taskPosition.latitude,
              global.globalSessionData.taskPosition.longitude),
          zoom: 15),
    ));

    print("3333333333333333333333333333333333333333333333333333333");

    /*location.onLocationChanged.listen((l) {
      dist = Geolocator.distanceBetween(global.globalSessionData.taskPosition.latitude,
          global.globalSessionData.taskPosition.longitude, l.latitude, l.longitude);
      DateTime variant = DateTime.now();
      if (dist <= 15000) {
        if (variant.hour <= 10 && variant.minute <= 10) {
          inl = true;
        } else {
          inl = false;
        }
        v = true;
      } else {
        v = false;
      }
      if (this.mounted) {
        setState(() {
          vis = v;
          isNotLate = inl;
        });
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final Marker _targetMarker = Marker(
      markerId: MarkerId(global.globalSessionData.docid),
      position: LatLng(global.globalSessionData.taskPosition.latitude,
          global.globalSessionData.taskPosition.longitude),
      infoWindow: InfoWindow(
        title: 'Task ' + global.globalSessionData.taskID.toString(),
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
    markerss.add(_targetMarker);
    return Scaffold(
      appBar: AppBar(
        title: Text('Lyfas On-Ground Support'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition),
              mapType: MapType.normal,
              mapToolbarEnabled: true,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              trafficEnabled: true,
              markers: markerss,
            ),
            /*Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () => {
                    showAlertDialog(context),
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.lightBlueAccent,
                  child: const Icon(Icons.all_out_outlined, size: 30.0),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}

/*
showAlertDialog(BuildContext context) {
  // Create button
  Widget okButton = FlatButton(
    child: Text("Completed Task"),
    onPressed: () async {
      //locationData(isNotLate);
      Navigator.of(context).pop();
    },
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Text("Task proximity"),
          content: Text(
              "You are nearby the task location. Your Location has been submitted."),
          actions: [
            okButton,
          ]);
    },
  );
}
*/
