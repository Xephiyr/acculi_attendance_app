import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:acculi_attendance_app/user_console.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

bool logged = global.globalSessionData.logged;

/*
* import 'package:acculi_attendance_app/nfc_auth.dart';
* import 'package:acculi_attendance_app/sign_in.dart';
*/
String name = global.globalSessionData.name;
Location location = new Location();

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  showAlertDialog(BuildContext context) {
    // set up the button
    return showDialog(
        context: context,
        builder: (BuildContext contexting) {
          return AlertDialog(
            title: Text('Attendance'),
            content: Text('Your Attendance has been logged'),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(contexting).pop(false);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    name = name[0].toUpperCase() + name.substring(1);
    var height, width;
    var displaysizes = MediaQuery.of(context).size;
    height = displaysizes.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    width = displaysizes.width;
    return Container(
      height: height,
      width: width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
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

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  enabled: !logged,
                  leading: Icon(Icons.add),
                  title: Text("Submit attendance"),
                  onTap: !logged
                      ? () async {
                          DateTime now = DateTime.now();

                          var pos;
                          pos = await location.getLocation();
                          GeoPoint point =
                              new GeoPoint(pos.latitude, pos.longitude);
                          Coordinates co =
                              Coordinates(pos.latitude, pos.longitude);
                          var addresses = await Geocoder.local
                              .findAddressesFromCoordinates(co);
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
                              global.globalSessionData.logged = true;
                              setState(() {
                                logged = true;
                              });
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
                            } else {
                              setState(() {
                                logged = true;
                                global.globalSessionData.logged = true;
                              });
                            }
                          }
                          if (query.size == 0) {
                            print(
                                'First attendance for the user has been logged');
                            setState(() {
                              logged = true;
                              global.globalSessionData.logged = true;
                            });
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
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
              padding: const EdgeInsets.all(8.0),
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
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.calendar_today_outlined),
                    title: Text("Apply for leave"),
                    onTap: () {
                      navigatorKey.currentState.pushNamed('/leave');
                    }),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  child: ListTile(
                      leading: const Icon(Icons.info),
                      title: Text("About"),
                      onTap: () async {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext bc) {
                              return Container(
                                child: new Wrap(
                                  children: <Widget>[
                                    new ListTile(
                                      title: new Text(
                                          'Attendii - Indigenious Attendance App of Acculi Labs Pvt. Ltd.'),
                                      subtitle: new Text(
                                          'Tailormade for multi-location, flexible working hours, hybrid device usage:- work from home, field operation setup'),
                                      isThreeLine: true,
                                    ),
                                  ],
                                ),
                              );
                            });
                      }),
                ),
              ),
            ),
            //Add buttons here
          ],
        ),
      ),
    );
  }
}

/*
showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                title: new Text(
                    'Attendii - Indigenious Attendance App of Acculi Labs Pvt. Ltd.'),
                subtitle: new Text(
                    'Tailormade for multi-location, flexible working hours, hybrid device usage:- work from home, field operation setup'),
                isThreeLine: true,
              ),
            ],
          ),
        );
      });
* */
/*
Padding(
              padding: const EdgeInsets.all(8.0),
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
* */
