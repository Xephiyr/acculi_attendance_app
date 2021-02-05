import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:location/location.dart';

var database = FirebaseFirestore.instance;
var c, m, hn, t, wi, wll, di;
var pos;
final Location location = Location();
final List<Marker> ret = List();
List<String> val = List();

class Work {
  bool completed;
  String mail;
  int hoursneeded;
  int task;
  int workId;
  GeoPoint workLatLng;
  String docId;

  Work(this.completed, this.mail, this.hoursneeded, this.task, this.workId, this.workLatLng,
      this.docId) {
    print("######################################");
    print("Some Shit i init " +
        this.completed.toString() +
        "   " +
        this.mail +
        "   " +
        this.hoursneeded.toString() +
        "   " +
        this.task.toString() +
        "" +
        this.workId.toString() +
        "   " +
        this.workLatLng.toString() +
        "" +
        this.docId);
  }
}

List<Work> dataPoints = List();
String email;
Marker target;

class Dashboard extends StatefulWidget {
  @override
  _Dashboard createState() => _Dashboard();
}

// LOGIC:::: Get markers from locations db, get description from point and use for titles for items in drawer
//Display message on the center of the screen to view attendance
class _Dashboard extends State<Dashboard> {
  List<Widget> obj = List<Widget>();
  var data;
  @override
  void initState() async {
    setState(() {
      data = _getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    email = ModalRoute.of(context).settings.arguments;
    val.clear();
    val.add(email);
    val.add("");
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

  Future<List<Work>> _getData() async {
    List<Work> dummy = List();
    database
        .collection('Work')
        .where('Email', whereIn: val)
        .get()
        .then((QuerySnapshot snapshot) => {
              snapshot.docs.forEach((f) {
                print(f.data());
                ret.clear();

                c = f.data()['Completed'];
                if (f.data()['Email'] == "") {
                  m = '';

                  print("Mail check here for no value for mail");
                } else {
                  m = f.data()['Email'];
                }

                hn = f.data()['HoursNeeded'];
                t = f.data()['Task'];
                wi = f.data()['WorkID'];
                wll = f.data()['WorkLatLng'];
                di = f.id;
                Work tests = Work(c, m, hn, t, wi, wll, di);
                dataPoints.add(tests);
                dummy.add(tests);
              })
            });
    await new Future.delayed(new Duration(seconds: 5));

    return dummy;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Work> values = snapshot.data;
    var temp1, temp2;
    return new ListView.builder(
        itemCount: values.length,
        itemBuilder: (context, index) {
          return new Column(
            children: <Widget>[
              new ListTile(
                title: Text("WorkID: " +
                    values[index].workId.toString() +
                    "   TaskID: " +
                    values[index].task.toString() +
                    " Email:" +
                    values[index].mail),
                subtitle: Text("Latitude :" +
                    values[index].workLatLng.latitude.toString() +
                    " Longitude:" +
                    values[index].workLatLng.longitude.toString()),
                isThreeLine: true,
                onTap: () async {
                  temp1 = values[index].mail;
                  temp2 = "";
                  if (temp1 == temp2) {
                    database
                        .collection("Work")
                        .doc(values[index].docId)
                        .update({"Email": email})
                        .then((value) => print("Updated"))
                        .catchError((error) => print("ErrorUpdating"));
                  }

                  print(
                      "00000000000000000000000000000000000000000000000000000000 added and sent Work obj 00000000000000");
                  Navigator.pushNamed(context, '/map', arguments: values[index]);
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
