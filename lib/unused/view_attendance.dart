import 'package:acculi_attendance_app/data_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

var database = FirebaseFirestore.instance;
List<int> days = List();
List<Position> datas = List();
final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
String m, n;
GeoPoint l;
Timestamp ts;
bool ot;
var t, check;

class AttendaceShowerStream extends StatefulWidget {
  @override
  _AttendaceShowerStreamState createState() => _AttendaceShowerStreamState();
}

class _AttendaceShowerStreamState extends State<
    AttendaceShowerStream> /*with AutomaticKeepAliveClientMixin<AttendaceShowerStream>*/ {
  Query att = database
      .collection('position')
      .where('Email', isEqualTo: user.email)
      .orderBy('Time');
  var dat;

  /*@override
  bool get wantKeepAlive => true;*/

  _AttendaceShowerStreamState() {
    days.clear();
    days.add(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Stream Attendance'),
      ),
      body: StreamBuilder(
        stream: att.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Align(
              alignment: Alignment.center,
              child: Text('Error'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Align(
              alignment: Alignment.center,
              child: LoadingFadingLine.circle(
                size: 50,
                backgroundColor: Colors.blue,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot doc) {
                m = doc.data()['Email'];
                l = doc.data()['Location'];
                n = doc.data()['Name'];
                ts = doc.data()['Time'];
                ot = doc.data()['onTime'];
                print(m.toString() + " " + l.toString() + " " + ts.toString());
                t = ts.toDate();
                Position dummy = Position(m, l, n, t);
                check = dummy.time.day;
                if (days.contains(check)) {
                  print("data already exists");
                } else {
                  days.add(check);
                  datas.add(dummy);
                  return new ListTile(
                    title: Text("Date   " +
                        dummy.time.day.toString() +
                        "." +
                        dummy.time.month.toString() +
                        "." +
                        dummy.time.year.toString() +
                        "   Time    " +
                        dummy.time.hour.toString() +
                        ":" +
                        dummy.time.minute.toString() +
                        ":" +
                        dummy.time.second.toString()),
                    subtitle: Text("Day:" +
                        DateFormat('EEEEE', 'en_US').format(dummy.time) +
                        "\n at Latitude :" +
                        dummy.location.latitude.toString() +
                        " at Longitude:" +
                        dummy.location.longitude.toString()),
                    isThreeLine: true,
                    onTap: () {
                      print('Enter into map here');
                    },
                  );
                }
              }).toList(),
            );
          }
          return Container(
            child: Align(
              alignment: Alignment.center,
              child: LoadingFadingLine.circle(
                size: 50,
                backgroundColor: Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }
}
