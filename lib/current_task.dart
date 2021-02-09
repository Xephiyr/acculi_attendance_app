import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:acculi_attendance_app/user_console.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

final db = FirebaseFirestore.instance;

class CurrentTask extends StatefulWidget {
  @override
  _CurrentTaskState createState() => _CurrentTaskState();
}

Location location = new Location();

/*
Future<void> setAttendance() async {
  DateTime now = DateTime.now();

  var pos;
  pos = await location.getLocation();
  GeoPoint point = new GeoPoint(pos.latitude, pos.longitude);
  Coordinates co = Coordinates(pos.latitude, pos.longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(co);
  var first = addresses.first;
  String mid;
  String address = '' + first.addressLine.toString();
  var len = address.length;
  mid = address.substring(0, len - 7);
  print(mid);
  var day = now.day;
  var month = now.month;

  var db = FirebaseFirestore.instance;
  final QuerySnapshot query = await db
      .collection('position')
      .where('Email', isEqualTo: global.globalSessionData.email)
      .orderBy(
        'Time',
        descending: false,
      )
      .limitToLast(1)
      .get();
  if (query.size != 0) {
    var snapshot = query.docs[0];
    DateTime uTime = snapshot.data()['Time'].toDate();
    print(uTime.toString());
    var uDay = uTime.day;
    var uMonth = uTime.month;
    bool checking;
    if (day == uDay) {
      if (month == uMonth) {
        checking = false;
      }
      if (month != uMonth) {
        checking = true;
      }
    } else if (day != uDay) {
      checking = true;
    }
    if (checking == true) {
      //add attendance
      print('First attendance for today');
      return db
          .collection("position")
          .add({
            'Email': global.globalSessionData.email,
            'Name': global.globalSessionData.name,
            'Location': GeoPoint(pos.latitude, pos.longitude),
            'Address': mid,
            'Time': now,
          })
          .then((value) => print("NoError in adding attendance"))
          .catchError((error) => print("Error"));
    }
  }
  if (query.size == 0) {
    print('First attendance for the user has been logged');
    return db
        .collection("position")
        .add({
          'Email': global.globalSessionData.email,
          'Name': global.globalSessionData.name,
          'Location': GeoPoint(pos.latitude, pos.longitude),
          'Address': mid,
          'Time': now,
        })
        .then((value) => print("NoError in adding attendance"))
        .catchError((error) => print("Error"));
  }
}
*/

class _CurrentTaskState extends State<CurrentTask> {
  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reselect Task?'),
            content: Text('Do you want to Reselect your task?'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  global.clearMessages();

                  var did;
                  did = global.globalSessionData.docid;
                  var myid = global.globalSessionData.myId;
                  db.collection('emp').doc(myid).get().then((f) {
                    if (f.data()['CurrentTask'] != "" &&
                        f.data()['CurrentTask'] == did) {
                      db
                          .collection('emp')
                          .doc(myid)
                          .update({'CurrentTask': ""}).then((f) {
                        var list = [global.globalSessionData.nfcID];
                        db.collection('WorkTest').doc(did).update({
                          'WorkID': FieldValue.arrayRemove(list),
                        }).then((f) {
                          print('Removed from task');
                        }).catchError((error) {
                          print('Error');
                        });
                        print('Removed task');
                      }).catchError((error) {
                        print('Error');
                      });
                    } else
                      print('Data not updated completely.....relax.');
                  });
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text(
            "Current Task",
            style: new TextStyle(color: Colors.white),
          ),
        ),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                  child: ListTile(
                    title: Text(global.globalSessionData.titlemsg),
                    subtitle: Text(global.globalSessionData.submsg),
                    isThreeLine: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                  child: ListTile(
                    title: Text(global.globalSessionData.taskPosition.latitude
                            .toString() +
                        "," +
                        global.globalSessionData.taskPosition.longitude
                            .toString()),
                    subtitle: Text('Location Coordinates'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                  child: ListTile(
                    title: Text("Task ID :" +
                        global.globalSessionData.taskID.toString().toString()),
                    subtitle: Text(global.globalSessionData.taskType),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton(
                        child: Text('View Location'),
                        onPressed: () async {
                          var did;
                          did = global.globalSessionData.docid;
                          var myid = global.globalSessionData.myId;
                          db
                              .collection('emp')
                              .doc(myid)
                              .update({'CurrentTask': did}).then((value) {
                            print('Updated');
                            var list = [global.globalSessionData.nfcID];
                            db.collection('WorkTest').doc(did).update({
                              'WorkID': FieldValue.arrayUnion(list),
                            }).then((f) {
                              print('Updated work');
                            }).catchError((error) {
                              print('Error');
                            });
                            navigatorKey.currentState.pushNamed('/map');
                          }).catchError((error) {
                            print('Error');
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                      child: TextButton(
                        child: Text('Completed'),
                        onPressed: () {
                          global.clearMessages();

                          var did;
                          did = global.globalSessionData.docid;
                          var myid = global.globalSessionData.myId;
                          db
                              .collection('emp')
                              .doc(myid)
                              .update({'CurrentTask': ''}).then((value) {
                            print('Completed');

                            db.collection('WorkTest').doc(did).update({
                              'Completed': true,
                            }).then((f) {
                              print('Updated work');
                            }).catchError((error) {
                              print('Error');
                            });
                          }).catchError((error) {
                            print('Error');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
