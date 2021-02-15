import 'package:acculi_attendance_app/data_models.dart';
import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

var database = FirebaseFirestore.instance;
List<int> days = List();
List<Position> datas = List();

String m, n;
String l;
Timestamp ts;
bool ot;
var t, check;
var i;
/*List<Position> attend = List();

Future<List<Position>> takeData() async {
  i = 0;
  days.clear();
  attend.clear();
  days.add(0);
  database
      .collection('position')
      .where('Email', isEqualTo: global.globalSessionData.email)
      .orderBy('Time')
      .get()
      .then((QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              print(f.data());
              var m, l, n, t, ot;
              var check;
              m = f.data()['Email'];
              l = f.data()['Location'];
              n = f.data()['Name'];
              ts = f.data()['Time'];

              print(m.toString() + " " + l.toString() + " " + ts.toString());
              t = ts.toDate();
              Position dummy = Position(m, l, n, t);

              attend.add(dummy);

              print(
                  '&&&&&&&&&&&&&&&&&&&&&& recieved data from position collection');
              print("Attend day" + dummy.time.day.toString());
              print(
                  "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
              i++;
            })
          });
  await new Future.delayed(new Duration(seconds: 5));
  print("total data rec:$i");
  return attend;
}*/

class AttendanceTab extends StatefulWidget {
  @override
  _AttendanceTabState createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab>
    with AutomaticKeepAliveClientMixin<AttendanceTab> {
  Query att;

  var dat;

  @override
  bool get wantKeepAlive => true;
  var data;

  /* @override
  void initState() {
    setState(() {
      data = takeData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Align(
              alignment: Alignment.center,
              child: LoadingFadingLine.circle(
                size: 50,
                backgroundColor: Colors.blue,
              ),
            );
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Position> values = snapshot.data;

    return new ListView.builder(
        itemCount: values.length,
        itemBuilder: (context, index) {
          return new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    title: Text("Date   " +
                        values[index].time.day.toString() +
                        "." +
                        values[index].time.month.toString() +
                        "." +
                        values[index].time.year.toString() +
                        "   Time    " +
                        values[index].time.hour.toString() +
                        ":" +
                        values[index].time.minute.toString() +
                        ":" +
                        values[index].time.second.toString()),
                    subtitle: Text("Day:" +
                        DateFormat('EEEEE', 'en_US')
                            .format(values[index].time) +
                        "\n at Latitude :" +
                        values[index].location.latitude.toString() +
                        " at Longitude:" +
                        values[index].location.longitude.toString()),
                    isThreeLine: true,
                  ),
                ),
              ),
              new Divider(
                height: 2.0,
              ),
            ],
          );
        });
  }*/

  void initState() {
    setState(() {
      att = database
          .collection('position')
          .where('Email', isEqualTo: global.globalSessionData.email)
          .orderBy('Time');
      days.clear();
      days.add(0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
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
        }
        if (!snapshot.hasData) {
          return Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: LoadingFadingLine.circle(
                    size: 50,
                    backgroundColor: Colors.blue,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('Error'),
                ),
              ],
            ),
          );
        } else
          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot doc) {
              m = doc.data()['Email'];
              String l = doc.data()['Address'];
              n = doc.data()['Name'];
              ts = doc.data()['Time'];
              var time = ts.toDate();
              var address = l;
              String mid;

              var len = address.length;
              mid = address.substring(0, len - 7);
              print(m.toString() + " " + l + " " + ts.toString());
              t = ts.toDate();

              return new Card(
                child: new ListTile(
                  title: Text("Date   " +
                      time.day.toString() +
                      "." +
                      time.month.toString() +
                      "." +
                      time.year.toString() +
                      "   Time    " +
                      time.hour.toString() +
                      ":" +
                      time.minute.toString() +
                      ":" +
                      time.second.toString()),
                  subtitle: Text("Day:" +
                      DateFormat('EEEEE', 'en_US').format(time) +
                      "\nAddress:" +
                      address),
                  isThreeLine: true,
                ),
              );
            }).toList(),
          );
      },
    );
  }
}
