import 'package:acculi_attendance_app/data_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:location/location.dart';

String tmail;

var database = FirebaseFirestore.instance;
bool isUnique = true;
var now = new DateTime.now();
Timestamp ts;
bool d, m, y;
List<int> days = List();
int i;
final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
Future<void> locationData(bool isNotLate) async {
  final Location location = Location();
  var pos;
  pos = await location.getLocation();

  return database
      .collection("position")
      .add({
        'Email': user.email,
        'Name': user.displayName,
        'Location': GeoPoint(pos.latitude, pos.longitude),
        'Time': DateTime.now().toUtc(),
        'onTime': isNotLate,
      })
      .then((value) => print("NoError"))
      .catchError((error) => print("Error"));
}

List<Position> attend = List();

Future<List<Position>> takeData() async {
  i = 0;
  days.clear();
  attend.clear();
  days.add(0);
  database
      .collection('position')
      .where('Email', isEqualTo: tmail)
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
              ot = f.data()['onTime'];
              print(m.toString() + " " + l.toString() + " " + ts.toString());
              t = ts.toDate();
              Position dummy = Position(m, l, n, t);
              check = dummy.time.day;
              if (days.contains(check)) {
                print("data already exists");
              } else {
                days.add(check);
                attend.add(dummy);
              }
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
}

class ShowDisplay extends StatefulWidget {
  @override
  _ShowDisplay createState() => _ShowDisplay();
}

class _ShowDisplay extends State<ShowDisplay> {
  var data;

  @override
  void initState() {
    setState(() {
      data = takeData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
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

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Home Page"),
      ),
      body: futureBuilder,
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Position> values = snapshot.data;

    return new ListView.builder(
        itemCount: values.length,
        itemBuilder: (context, index) {
          return new Column(
            children: <Widget>[
              new ListTile(
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
                    DateFormat('EEEEE', 'en_US').format(values[index].time) +
                    "\n at Latitude :" +
                    values[index].location.latitude.toString() +
                    " at Longitude:" +
                    values[index].location.longitude.toString()),
                isThreeLine: true,
                onTap: () {
                  print('Enter into map here');
                },
              ),
              new Divider(
                height: 2.0,
              ),
            ],
          );
        });
  }
}
//DONT PASS TILL WORKID IS OBTAINED
