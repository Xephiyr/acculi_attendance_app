import 'package:acculi_attendance_app/the_user.dart' as global;
import 'package:acculi_attendance_app/user_console.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

final db = FirebaseFirestore.instance;

int index = 0;

List<String> woID = new List(4);

class TaskTab extends StatefulWidget {
  @override
  _TaskTabState createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab>
    with AutomaticKeepAliveClientMixin<TaskTab> {
  Query workers;
  bool selection = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    setState(() {
      global.clearMessages();
      workers = FirebaseFirestore.instance.collection('WorkTest');
    });
    super.initState();
  }

  showAlertDialog(BuildContext context, String address, int task,
      GeoPoint workLatLng, String docID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("TaskID is:" + task.toString()),
          content: Text("Do you want to choose the selected task?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Back"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Select Task"),
              onPressed: () async {
                global.globalSessionData.docid = docID;
                global.globalSessionData.taskID = task;
                global.globalSessionData.taskPosition = workLatLng;
                global.globalSessionData.address = address;
                global.globalSessionData.titlemsg = "" + address;
                global.globalSessionData.submsg = "In progress";
                navigatorKey.currentState.pushNamed('/current');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
            stream: workers.snapshots(),
            builder: (BuildContext contexting,
                AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  var c, wll;
                  int t;
                  //var wi,ids
                  String docid;

                  c = doc.data()['Completed'];
                  t = doc.data()['TaskID'];
                  var add = doc.data()['Address'];
                  Icon icon;
                  switch (t) {
                    case 1:
                      icon = Icon(Icons.grass);
                      global.globalSessionData.taskType = 'Field Task';
                      break;
                    case 2:
                      icon = Icon(Icons.local_hospital);
                      global.globalSessionData.taskType = 'Task at a Clinic';
                      break;
                    case 3:
                      icon = Icon(Icons.work);
                      global.globalSessionData.taskType =
                          'Task at an office space';
                      break;
                    case 4:
                      icon = Icon(Icons.emoji_transportation);
                      global.globalSessionData.taskType = 'Task at a hotel';
                      break;
                    case 5:
                      icon = Icon(Icons.celebration);
                      global.globalSessionData.taskType = 'Task at an event';
                      break;
                    case 6:
                      icon = Icon(Icons.emoji_people);
                      global.globalSessionData.taskType = 'Other type of Task';
                      break;
                    default:
                      icon = Icon(Icons.emoji_objects_outlined);
                  }
                  // wi = doc.data()['WorkID'];
                  wll = doc.data()['WorkLatLng'];
                  docid = doc.id;

                  return Card(
                    child: new ListTile(
                      leading: icon,
                      title: Text(add),
                      subtitle: Text('Completed:$c'),
                      isThreeLine: true,
                      dense: false,
                      onTap: () {
                        showAlertDialog(contexting, add, t, wll, docid);
                      },
                      enabled: !selection,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
/*
Container(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(global.globalSessionData.titlemsg),
                      subtitle: Text(global.globalSessionData.submsg),
                      isThreeLine: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: TextButton(
                            child: Text('Reselect Task?'),
                            onPressed: !selection
                                ? null
                                : () {
                                    global.clearMessages();
                                    setState(() {
                                      selection = false;
                                    });
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
                                  },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextButton(
                            child: Text('View Location'),
                            onPressed: !selection
                                ? null
                                : () {
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
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => MapCaller()));
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
                            onPressed: !selection
                                ? null
                                : () {
                                    global.clearMessages();
                                    setState(() {
                                      selection = false;
                                    });
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
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.black,
          height: 20,
          thickness: 5,
          indent: 0,
          endIndent: 0,
        ),
* */
