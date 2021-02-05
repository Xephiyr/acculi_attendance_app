import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:acculi_attendance_app/the_user.dart' as global;

final DateTime currentDate = DateTime.now();
final firestore = FirebaseFirestore.instance;

final DateTime first =
    new DateTime(currentDate.year, currentDate.month, currentDate.day - 2);
final DateTime last = new DateTime(currentDate.year, 12, 31);
String email = global.globalSessionData.email;
final bool status = false;
final String nfcId = global.globalSessionData.nfcID;
var st, count, docid, fd, td, wll;
final String remarks = 'No remarks';

DateFormat df = new DateFormat('dd-MM-yyyy');
String reason;
int days;
DateTime endDate, startDate;

var reasonCntrlr = TextEditingController();
var dateCntrlr = TextEditingController();
var enddateCntrlr = TextEditingController();
var daysCntrlr = TextEditingController();

class LeaveForm extends StatefulWidget {
  @override
  _LeaveFormState createState() => _LeaveFormState();
}

Future<String> onSubmit(DateTime start, DateTime end) async {
  String message;
  await firestore.collection('leaveperm').add({
    'Email': global.globalSessionData.email,
    'Name': global.globalSessionData.name,
    'fromDate': start,
    'nfcId': nfcId,
    'reason': reason,
    'status': 1,
    'todate': end,
    'remarks': remarks,
  }).then((value) {
    print('Successfully added');
    message = "Success";
  }).catchError((error) {
    print('Error :$error');
    message = null;
  });
  return message;
}

class _LeaveFormState extends State<LeaveForm> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lyfas On-Ground Support'),
      ),
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: dateCntrlr,
                  decoration: const InputDecoration(
                    hintText: 'Enter the starting date for your leave request ',
                    labelText: 'Starting date',
                  ),
                  onTap: () async {
                    DateTime date = DateTime(2021);
                    FocusScope.of(context).requestFocus(new FocusNode());

                    date = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: first,
                      lastDate: last,
                    );
                    dateCntrlr.text = df.format(date);
                    print('00000000000000000000000000000000000000000000000000');
                    print('00000000000000000000000000000000000000000000000000');
                    print(dateCntrlr.text);
                    print('00000000000000000000000000000000000000000000000000');
                    print('00000000000000000000000000000000000000000000000000');
                    setState(() {
                      startDate = date;
                    });
                  },
                  validator: (date) {
                    if (date.isEmpty) {
                      return 'Date cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: enddateCntrlr,
                  decoration: const InputDecoration(
                    hintText: 'Enter the ending date for your leave request',
                    labelText: 'Ending Date',
                  ),
                  onTap: () async {
                    DateTime date = DateTime(2021);
                    FocusScope.of(context).requestFocus(new FocusNode());

                    date = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: first,
                      lastDate: last,
                    );
                    enddateCntrlr.text = df.format(date);
                    print('00000000000000000000000000000000000000000000000000');
                    print('00000000000000000000000000000000000000000000000000');
                    print(enddateCntrlr.text);
                    print('00000000000000000000000000000000000000000000000000');
                    print('00000000000000000000000000000000000000000000000000');
                    setState(() {
                      endDate = date;
                    });
                  },
                  validator: (date) {
                    if (date.isEmpty) {
                      return 'Date cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                    controller: reasonCntrlr,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter reason for leave request',
                      labelText: 'Reason',
                      helperText:
                          'Please enter a reason for your leave request',
                    ),
                    maxLines: 4,
                    validator: (reason) {
                      if (reason.isEmpty) {
                        return 'Reason cannot be empty';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 100, right: 100, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a Snackbar.
                          reason = reasonCntrlr.text;
                          String val = await onSubmit(startDate, endDate);
                          if (val != null) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Data is in processing.')));
                            await new Future.delayed(new Duration(seconds: 4));
                            reasonCntrlr.clear();
                            dateCntrlr.clear();
                            enddateCntrlr.clear();
                            Navigator.pop(context);
                          }
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowHistory extends StatefulWidget {
  @override
  _ShowHistoryState createState() => _ShowHistoryState();
}

class _ShowHistoryState extends State<ShowHistory> {
  Query workers;
  QuerySnapshot check;
  bool stat;

  @override
  void initState() {
    setState(() {
      workers = FirebaseFirestore.instance
          .collection('leaveperm')
          .where('Email', isEqualTo: global.globalSessionData.email)
          .where('nfcId', isEqualTo: global.globalSessionData.nfcID);
    });
    super.initState();
  }

  void getStatus() async {
    check = await workers.get();
    if (check.size != 0) {
      setState(() {
        stat = true;
      });
    } else
      setState(() {
        stat = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("History"),
      ),
      resizeToAvoidBottomInset: false,
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
          if (snapshot.hasData == true) {
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot doc) {
                st = doc.data()['status'];
                fd = doc.data()['fromDate'];
                td = doc.data()['todate'];
                var rem = doc.data()['remarks'];
                if (rem == null) rem = remarks;
                Color color = Colors.yellowAccent;
                String msg;
                String sd, ed;
                sd = df.format(fd.toDate());
                ed = df.format(td.toDate());
                if (st == 1) {
                  msg = 'Under processing';
                }
                if (st == 2) {
                  msg = 'Request Approved';
                  color = Colors.green;
                }
                if (st == 0) {
                  msg = 'Request Denied';
                  color = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      isThreeLine: true,
                      title: Text('From : ' + sd + ' To : ' + ed),
                      subtitle: Text('Approval status : ' +
                          msg +
                          '\n' +
                          'Remarks :' +
                          rem),
                      trailing: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: 20,
                          height: 30,
                          decoration:BoxDecoration(
                            shape:BoxShape.circle,
                            color:color,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            return Container(
              child: Align(
                alignment: Alignment.center,
                child: Text('No Data found'),
              ),
            );
          }
        },
      ),
    );
  }
}
