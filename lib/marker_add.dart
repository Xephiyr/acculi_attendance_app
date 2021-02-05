import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

List<String> woID = new List(4);

Set<Marker> markerss = {};
Set<Marker> markers2 = {};
Set<Marker> mark = {};
LatLng ret;
final firestore = FirebaseFirestore.instance;

var clat, clon;

class Item {
  const Item(this.name, this.icon, this.taskn);

  final String name;
  final Icon icon;
  final int taskn;
}

List<Item> tasks = <Item>[
  const Item('Field', Icon(Icons.grass), 1),
  const Item('Clinic', Icon(Icons.local_hospital), 2),
  const Item('Office', Icon(Icons.work), 3),
  const Item('Hotel', Icon(Icons.emoji_transportation), 4),
  const Item('Events', Icon(Icons.celebration), 5),
  const Item('Other', Icon(Icons.emoji_people), 6),
];

class MapMarker extends StatefulWidget {
  @override
  _MapMarker createState() => _MapMarker();
}

class _MapMarker extends State<MapMarker> {
  LatLng _initialcameraposition = LatLng(12.9159355, 77.5207615);
  Item selectedTask;
  GoogleMapController controller;
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  getLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void initState() {
    getLocationPermission();
    markerss.clear();

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    super.dispose();
  }

  var pos;
  var current;

  Future<void> addGeoPoint(tas) async {
    GeoPoint point = new GeoPoint(clat, clon);
    Coordinates co = Coordinates(clat, clon);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(co);
    var first = addresses.first;
    String mid;
    String address = '' + first.addressLine.toString();
    var len = address.length;
    mid = address.substring(0, len - 7);
    var docid;
    await firestore.collection('WorkTest').add({
      'Completed': false,
      'Email': "",
      "TaskID": int.parse(tas),
      "WorkID": woID,
      'WorkLatLng': point,
      'Address': mid,
    }).then((value) {
      docid = value.id;
      print(docid);
    }).catchError((error) => print(
        "111111111111111111111111111111111111111111111Failed to add user: $error"));
    setState(() {
      final Marker marker = Marker(
        markerId: MarkerId(docid),
        position: LatLng(clat, clon),
        infoWindow: InfoWindow(title: 'Target Location', snippet: 'ID $tas'),
        icon: BitmapDescriptor.defaultMarkerWithHue(100),
      );
      markerss.add(marker);
      print("----------------------------------");
      print(marker.toString());
      print("----------------------------------");
    });
  }

  void _onMapCreated(GoogleMapController _cntlr) async {
    location.enableBackgroundMode();
    pos = await location.getLocation();
    await getData();
    setState(() {
      controller = _cntlr;
    });
    await controller.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15),
    ));
    print(
        '0000000000000000000000000000000000000000000000000000000000000000000');
    print(markerss.length.toString());
    print(
        '0000000000000000000000000000000000000000000000000000000000000000000');
  }

  Future<void> getData() async {
    FirebaseFirestore.instance
        .collection('WorkTest')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                GeoPoint l = doc.data()['WorkLatLng'];
                print("******************************************************");
                setState(() {
                  final Marker marker = Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(l.latitude, l.longitude),
                    infoWindow: InfoWindow(
                        title: 'Task :' + doc.data()['TaskID'].toString(),
                        snippet:
                            doc.data()['HoursNeeded'].toString() + ' hours'),
                    icon: BitmapDescriptor.defaultMarker,
                  );
                  setState(() {
                    markerss.add(marker);
                  });

                  print('++++++++++++++++++++++++++++++++++++++++');
                  print(marker.toString());
                  print('++++++++++++++++++++++++++++++++++++++++');
                  print(markerss.length.toString());
                  print('++++++++++++++++++++++++++++++++++++++++');
                });
              })
            });
  }

  displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter additional details'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<Item>(
                    hint: Text("Select Type"),
                    value: selectedTask,
                    onChanged: (Item value) {
                      setState(() {
                        selectedTask = value;
                        print(selectedTask.taskn.toString());
                      });
                    },
                    items: tasks.map((Item tasks) {
                      return DropdownMenuItem<Item>(
                        value: tasks,
                        child: Row(
                          children: <Widget>[
                            tasks.icon,
                            SizedBox(width: 10),
                            Text(tasks.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SUBMIT'),
                onPressed: () async {
                  print(selectedTask.taskn.toString());
                  addGeoPoint(selectedTask.taskn.toString());
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
              onCameraMove: (CameraPosition position) {
                clat = position.target.latitude;
                clon = position.target.longitude;
              },
              myLocationEnabled: true,
              trafficEnabled: true,
              markers: markerss,
            ),
            Align(
              alignment: Alignment(0, -0.044),
              child: new Icon(Icons.location_pin, size: 40.0),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () => {
                    displayDialog(context),
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.lightBlueAccent,
                  child: const Icon(Icons.all_out_outlined, size: 30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
