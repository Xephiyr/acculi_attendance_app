import 'dart:io';

import 'package:acculi_attendance_app/sign_in.dart';
import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:acculi_attendance_app/user_console.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

/*
* import 'package:acculi_attendance_app/nfc_auth.dart';
* import 'package:acculi_attendance_app/sign_in.dart';
*/
String name = global.globalSessionData.name;
Location location = new Location();

class UserPage extends StatelessWidget {
  bool logged = false;
  showAlertDialog(BuildContext context) {
    // set up the button
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attendance'),
            content: Text('Your Attendance has already been logged'),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    name = name[0].toUpperCase() + name.substring(1);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Card(
                elevation: 5,
                child: ListTile(
                  title: Text('Name : ' + name),
                  subtitle: Text('NfcID : ' +
                      global.globalSessionData.nfcID +
                      "\n" +
                      "Email : " +
                      global.globalSessionData.email +
                      "\n" +
                      "Phone :" +
                      global.globalSessionData.phoneNo),
                  isThreeLine: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text("Submit attendance"),
                  onTap: () async {
                    if (logged == true) {
                      showAlertDialog(context);
                    }
                    if (logged == false) {
                      DateTime now = DateTime.now();

                      var pos;
                      pos = await location.getLocation();
                      GeoPoint point =
                          new GeoPoint(pos.latitude, pos.longitude);
                      Coordinates co = Coordinates(pos.latitude, pos.longitude);
                      var addresses =
                          await Geocoder.local.findAddressesFromCoordinates(co);
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
                          .where('Email',
                              isEqualTo: global.globalSessionData.email)
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
                          logged = true;
                          print('First attendance for today');
                          return db
                              .collection("position")
                              .add({
                                'Email': global.globalSessionData.email,
                                'Name': global.globalSessionData.name,
                                'Location':
                                    GeoPoint(pos.latitude, pos.longitude),
                                'Address': mid,
                                'Time': now,
                              })
                              .then((value) =>
                                  print("NoError in adding attendance"))
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
                            .then((value) =>
                                print("NoError in adding attendance"))
                            .catchError((error) => print("Error"));
                      }
                    }
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.add_location_alt),
                title: Text("Add new task marker"),
                onTap: () {
                  print('Logging attendance');
                  navigatorKey.currentState.pushNamed('/marker');
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text("View leave history"),
                  onTap: () {
                    navigatorKey.currentState.pushNamed('/history');
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text("Apply for leave"),
                  onTap: () {
                    navigatorKey.currentState.pushNamed('/leave');
                  }),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                    onTap: () async {
                      await signOutOf();
                      exit(0);
                    }),
              ),
            ),
          ),
          //Add buttons here
        ],
      ),
    );
  }
}

Future<void> setAttendance() async {}
