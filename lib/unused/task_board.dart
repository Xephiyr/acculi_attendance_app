import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:acculi_attendance_app/data_models.dart';

var concat = StringBuffer();
var c, wi, wll, ids, docid;
var pos;
int t, hn, count;
List<String> woID = new List(4);
WorkTest dummy;

class TaskBoard extends StatefulWidget {
  @override
  _TaskBoardState createState() => _TaskBoardState();
}

class _TaskBoardState extends State<TaskBoard> {
  final Query workers = FirebaseFirestore.instance
      .collection('WorkTest')
      .where('Completed', isEqualTo: false)
      .where('WorkerCount', isLessThanOrEqualTo: 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Tasks"),
      ),
      body: StreamBuilder(
        stream: workers.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Align(
              alignment: Alignment.center,
              child: LoadingFadingLine.circle(
                size: 50,
                backgroundColor: Colors.blue,
              ),
            );
          }
          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot doc) {
              c = doc.data()['Completed'];
              hn = doc.data()['HoursNeeded'];
              t = doc.data()['TaskID'];

              // wi = doc.data()['WorkID'];
              wll = doc.data()['WorkLatLng'];
              count = doc.data()['WorkerCount'];
              docid = doc.id;
              dummy = WorkTest(c, t, wll, docid);

              return new ListTile(
                title: Text('Completed Status:$c' + ' ' + 'Task Id:$t'),
                subtitle: Text('HoursNeeded:$hn' + ' ' + 'Currently working:' + count.toString()),
                isThreeLine: true,
                onTap: () async {
                  showAlertDialog(context, dummy);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

showAlertDialog(BuildContext context, WorkTest sampledata) {
  // Create button
  Widget takeTask = FlatButton(
    child: Text("Select Task"),
    onPressed: () async {
      Navigator.of(context).pop();

      Navigator.pushNamed(context, '/map', arguments: sampledata);
    },
  );
  Widget back = FlatButton(
    child: Text("Back"),
    onPressed: () async {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Text("TaskID is:" + sampledata.task.toString()),
          content: Text("Do you want to choose the selected task?"),
          actions: [back, takeTask]);
    },
  );
}
